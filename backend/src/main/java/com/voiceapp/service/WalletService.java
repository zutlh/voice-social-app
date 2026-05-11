package com.voiceapp.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.voiceapp.dto.WalletResponse;
import com.voiceapp.model.UserCoinAccount;
import com.voiceapp.repository.UserCoinAccountMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class WalletService {

    private final UserCoinAccountMapper accountMapper;

    public WalletResponse getWallet(Long userId) {
        UserCoinAccount account = accountMapper.selectOne(
                new LambdaQueryWrapper<UserCoinAccount>().eq(UserCoinAccount::getUserId, userId));
        if (account == null) {
            return new WalletResponse(0, 0, 0);
        }
        return new WalletResponse(account.getBalance(), account.getTotalRecharged(), account.getTotalSpent());
    }
}
