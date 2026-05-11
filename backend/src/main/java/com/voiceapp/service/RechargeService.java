package com.voiceapp.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.voiceapp.common.BizException;
import com.voiceapp.common.ErrorCode;
import com.voiceapp.dto.RechargePlanResponse;
import com.voiceapp.model.RechargeOrder;
import com.voiceapp.model.UserCoinAccount;
import com.voiceapp.repository.RechargeOrderMapper;
import com.voiceapp.repository.UserCoinAccountMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RechargeService {

    private final RechargeOrderMapper orderMapper;
    private final UserCoinAccountMapper coinAccountMapper;
    private final StringRedisTemplate redisTemplate;

    private static final String COIN_KEY = "coin:balance:";

    private static final List<RechargePlanResponse> PLANS = Arrays.asList(
            new RechargePlanResponse("basic", 6, 60, 0, "com.voice.coins.60"),
            new RechargePlanResponse("standard", 30, 300, 10, "com.voice.coins.300"),
            new RechargePlanResponse("large", 98, 980, 50, "com.voice.coins.980"),
            new RechargePlanResponse("luxury", 298, 2980, 200, "com.voice.coins.2980")
    );

    public List<RechargePlanResponse> getPlans() {
        return PLANS;
    }

    @Transactional
    public void mockRecharge(Long userId, String planId) {
        RechargePlanResponse plan = PLANS.stream()
                .filter(p -> p.getPlanId().equals(planId))
                .findFirst()
                .orElseThrow(() -> new BizException(ErrorCode.PARAM_ERROR));

        int coins = plan.getCoins() + plan.getBonus();

        RechargeOrder order = new RechargeOrder();
        order.setUserId(userId);
        order.setAmountYuan(BigDecimal.valueOf(plan.getAmountYuan()));
        order.setCoins(coins);
        order.setStatus("SUCCESS");
        orderMapper.insert(order);

        addCoins(userId, coins);
    }

    @Transactional
    public void verifyReceipt(Long userId, String receipt) {
        log.info("Apple receipt verify: userId={}, receipt={}", userId,
                receipt != null ? receipt.substring(0, Math.min(50, receipt.length())) : "null");
    }

    public List<RechargeOrder> listOrders(Long userId) {
        return orderMapper.selectList(
                new LambdaQueryWrapper<RechargeOrder>()
                        .eq(RechargeOrder::getUserId, userId)
                        .orderByDesc(RechargeOrder::getCreatedAt));
    }

    private void addCoins(Long userId, int coins) {
        redisTemplate.opsForValue().increment(COIN_KEY + userId, coins);

        UserCoinAccount account = coinAccountMapper.selectOne(
                new LambdaQueryWrapper<UserCoinAccount>().eq(UserCoinAccount::getUserId, userId));
        if (account == null) {
            account = new UserCoinAccount();
            account.setUserId(userId);
            account.setBalance(coins);
            account.setTotalRecharged(coins);
            coinAccountMapper.insert(account);
        } else {
            account.setBalance(account.getBalance() + coins);
            account.setTotalRecharged(account.getTotalRecharged() + coins);
            coinAccountMapper.updateById(account);
        }
    }
}
