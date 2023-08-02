import os
import ButlerRobot.keywords.vault as vault
from robot.libraries.BuiltIn import BuiltIn


credentials = {
    'odoo_user': 'gAAAAABkXfVcux9FphTue5BP3jvf4X73f5JId5EqVZadOcZJOQinzxZn1g0jvjw7KtLxmq2QmLXWptC-I_IIcQ3i9PNZPXex_c4jE5AKAZ2LVmn1q7117u4=',
    'odoo_pass': 'gAAAAABkXfV7dPgwud0eq2NF9E7NuuMMYpUhImWJRACyd8epmomNeneKsmSWTvIfQPkl9YVbDHKt-yCglLyILVoEsWPEMQDw4SIvRKVLt1eGn7Vra6vkNoU=',
    'amazon_user_flendu': 'gAAAAABkQRRpB-F3IN9FAcrTxlAAEuMcnQiF0JRx8qZBHXyxw-pIUDl26BrMehMCKtiqOs12utj7O6hvQpqiUJiiVWEPwihFzA==',
    'amazon_pass_flendu': 'gAAAAABkQQ-cS29l1B7fmtReo2nKvWk5ExYYBgIPEX43bhOJIDSrmHJQQJH-15L4IY97GyrA3k0anX2TDaTrmxfFGk0Uln_DMQ==',
    'amazon_user': 'gAAAAABkSP8xE5uDjEs8YzAWgeSxsRtr09NmcL-PpDaw-afb97EpzscWWIIZzUQe2sNmZjhHF7DIfggSz2vk8xBqei-9D8e-PDIaX33MiAXNWA61LkAo2UY=',
    'amazon_pass': 'gAAAAABkSP9PTs90CYOVaQEV_EuJznsDxwqkTc7zxAx-T_lsJWCnYkNvB7TgEHsLDv3_y9FzHSDJzHSQlMFEkPBgryvbEyyCuQ==',
    'woocommerce_user': 'gAAAAABkwPmaICENOV7Nd4cB9ez3SrGiZkypV8LHteWMAA2Grs1HYVeR6J1tIfaOhnfIU9ftZpHsnIuBDWDFrIfo-PE0alvqLT5naWnnLUkuia6r7osqS7w=',
    'woocommerce_pass': 'gAAAAABkwPnqdW_4XIAg9XzPd4HL3BsTM7qv5ehN5nS5AmhYpWNnz80yC7t37tLXbG1oG0AqjAg_IRugTC-OwuwK76ViPMkhrA==',
    'ebay_user': 'gAAAAABkwUXsOssO25JsjZ4iCe2to2ntKKsgrwiKw2_qRuxslAq6Fw5cK3hFBVPFEOtaPWBuZ5Rv0R5DYsYbsCDfpsT_A10xhsGX7r75Q_smFEo7oA5xn88=',
    'ebay_pass': 'gAAAAABkwUYP9QmyaZL_YksOGhIRf1RLfOWyYPbXupntmxuR-D3WVnnRxFCaiRQC66E2RTdRqKtQfFi92CMgkvPc2McONNXVzuJQNuxics0H7TnjaJUhvjg=',
    'otp_amazon': 'gAAAAABkSQDA209MCJ0oxWJyFtHTfLoHz-DSfTgFAuhb_936uKPLbFceBdbaPyZ0iYDbgN_HLKHulhqzpL6xhgNo2y8s_7AI4X1lrqYkJZ6AIrYrLjx_qSyWixS_dOv7EPN3U9pyUjUewmd-n6jaUn89v0fpemTY6w==',
    'otp_amazon_flendu': 'gAAAAABkQQ-cUSZNeaOUCgfqrBtvu3Nn-3zwG7OZZHFikFasw1ibGRvIoNBRgekXSZDJz8JjNflPObMAYbWL9qCf3jcy2MmTocoZUZ8TnlweW6M6fKpAf41SXu4ip21ds0aBlld6-UaYs52HJxQdUcO0yydI8iGCrg=='
}


def get_variables():
    pass_ = BuiltIn().get_variable_value('${ROBOT_CICLOZERO_PASS}', os.environ.get('ROBOT_CICLOZERO_PASS'))
    assert pass_, 'Password not found. Define ROBOT_CICLOZERO_PASS environment variable or set it as variable.'
    return vault.get_credentials(pass_, credentials)
