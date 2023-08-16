## Audit Anomalies Archive

This repository is designed to maintain a record of unique and fundamental vulnerabilities I discover during my smart contract audits. All the issues documented here have been reproduced using Foundry.

## List of Issues
[20230814 Issue#1](#issue-1---denial-of-servicedos-due-to-hardcoding-of-decimals)
[20230816 Issue#2](#issue-1---denial-of-servicedos-due-to-hardcoding-of-decimals)

---

### Issue 1 - Denial of Service(DoS) due to hardcoding of DECIMALS

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

Test
```
forge test --match-contract IssueTwoTest -vv
```

#### Contract
[MetaNFT.sol](src/Issue2/MetaNFT.sol)

#### Link Reference
[Read The Issue#2 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-1-7caf714fec8b)
[Link to Report]()
---
