## Audit Anomalies Archive

This repository is designed to maintain a record of unique and fundamental vulnerabilities I discover during my smart contract audits. All the issues documented here have been reproduced using Foundry.

Inspired from SunSec(https://twitter.com/1nf0s3cpt)

## List of Issues
[20230814 Issue#1](#issue-1---denial-of-servicedos-due-to-hardcoding-of-decimals)

[20230816 Issue#2](#issue-2---users-losing-funds-due-to-missing-functionality-to-refund-extra-ether-sent)

---

### Issue 1 - Denial of Service(DoS) due to hardcoding of DECIMALS
Summary

The developers typically make assumptions, such as assuming that all ERC20 tokens have 18 decimal places. They then hardcode this assumed value into the contract. However, issues arise when ERC20 tokens with different decimal places interact with the contract. It's at this point that they realize the mistake they've made.

Test
```
forge test --match-contract IssueOneTest -vv
```

#### Contract
[Vault4626.sol](src/Issue1/Vault4626.sol)

#### Link Reference
[Read The Issue#1 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-1-7caf714fec8b)

---
### Issue 2 - Users losing funds due to missing functionality to refund extra ETHER sent
Summary

When implementing payable functions, the developer must monitor the amount of Ether sent to them via `msg.value`. If this amount exceeds the required value, it's crucial for the developer to initiate a refund back to the user. Failing to execute this step accurately could essentially be viewed as taking funds from the user without rightful cause.

Test
```
forge test --match-contract IssueTwoTest -vv
```

#### Contract
[MetaNFT.sol](src/Issue2/MetaNFT.sol)

#### Link Reference
[Read The Issue#2 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-2-eb34fcbcee18)

[Link to Report](https://github.com/solodit/solodit_content/blob/main/reports/AuditOne/2023-04-13-Lotaheros.md#calling-mintfounderhero-may-may-accidently-lock-user-funds)

---
