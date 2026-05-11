package com.voiceapp.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.voiceapp.common.BizException;
import com.voiceapp.common.ErrorCode;
import com.voiceapp.dto.GiftResponse;
import com.voiceapp.dto.SendGiftRequest;
import com.voiceapp.model.Gift;
import com.voiceapp.model.GiftRecord;
import com.voiceapp.model.UserCoinAccount;
import com.voiceapp.repository.GiftMapper;
import com.voiceapp.repository.GiftRecordMapper;
import com.voiceapp.repository.UserCoinAccountMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class GiftService {

    private final GiftMapper giftMapper;
    private final GiftRecordMapper giftRecordMapper;
    private final UserCoinAccountMapper coinAccountMapper;
    private final StringRedisTemplate redisTemplate;

    private static final String COIN_KEY = "coin:balance:";

    public List<GiftResponse> listGifts() {
        return giftMapper.selectList(null).stream().map(g -> {
            GiftResponse r = new GiftResponse();
            r.setId(g.getId());
            r.setName(g.getName());
            r.setIcon(g.getIcon());
            r.setPrice(g.getPrice());
            r.setType(g.getType());
            r.setSortOrder(g.getSortOrder());
            return r;
        }).collect(Collectors.toList());
    }

    @Transactional
    public void sendGift(Long fromUid, SendGiftRequest request) {
        Gift gift = giftMapper.selectById(request.getGiftId());
        if (gift == null) throw new BizException(ErrorCode.GIFT_NOT_FOUND);

        int totalCoins = gift.getPrice() * request.getQuantity();

        String key = COIN_KEY + fromUid;
        Long remaining = redisTemplate.opsForValue().decrement(key, totalCoins);
        if (remaining == null || remaining < 0) {
            redisTemplate.opsForValue().increment(key, totalCoins);
            throw new BizException(ErrorCode.INSUFFICIENT_COINS);
        }

        try {
            GiftRecord record = new GiftRecord();
            record.setFromUid(fromUid);
            record.setToUid(request.getToUid());
            record.setGiftId(request.getGiftId());
            record.setQuantity(request.getQuantity());
            record.setRoomId(request.getRoomId());
            record.setTotalCoins(totalCoins);
            giftRecordMapper.insert(record);

            UserCoinAccount account = coinAccountMapper.selectOne(
                    new LambdaQueryWrapper<UserCoinAccount>().eq(UserCoinAccount::getUserId, fromUid));
            if (account != null) {
                account.setBalance(account.getBalance() - totalCoins);
                account.setTotalSpent(account.getTotalSpent() + totalCoins);
                coinAccountMapper.updateById(account);
            }
        } catch (Exception e) {
            redisTemplate.opsForValue().increment(key, totalCoins);
            throw new BizException(ErrorCode.INTERNAL_ERROR, "送礼失败");
        }
    }
}
