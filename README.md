## Audit Anomalies Archive

This repository is designed to maintain a record of unique and fundamental vulnerabilities I discover during my smart contract audits. All the issues documented here have been reproduced using Foundry.

Inspired from SunSec(https://twitter.com/1nf0s3cpt)

## List of Issues
[20230814 Issue#1](#issue-1---denial-of-servicedos-due-to-hardcoding-of-decimals)

[20230816 Issue#2](#issue-2---users-losing-funds-due-to-missing-functionality-to-refund-extra-ether-sent)

[20230826 Issue#3](#issue-3---skipping-the-payment-of-platform_fee-because-of-user-controlled-input-parameters)

[20230908 Issue#4](#issue-4---custom-upgrdable-contract-leading-to-double-iniitlization)

[20230914 Issue#5](#issue-4---custom-upgrdable-contract-leading-to-double-iniitlization)

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
### Issue 2 - Users losing funds due to missing functionality to refund extra ether(msg.value) sent
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

### Issue 3 - Skipping the payment of platform_fee because of user controlled input parameters
Summary

The issue highlights the potential vulnerabilities arising from unchecked user inputs in smart contracts. It demonstrates how failure to validate inputs can lead to malicious users evading fees. Smart contract developers are urged to assess input requirements and conduct thorough testing of input parameters controlled by users.

Test
```
forge test --match-contract IssueThreeTest -vv
```

#### Contract
[BatchTokenTransfer.sol](src/Issue3/BatchTokenTransfer.sol)

#### Link Reference
[Read The Issue#3 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-3-bf0eccfbaf0c)

[Link to Report](https://github.com/UNSNARL/audit-reports/blob/main/Dropzone_Komet_Security_Assessment.pdf)

---
### Issue 4 - Custom Upgradable Contract Leading to Double Initialization

Summary

Writing custom code for functions or logic that's already available is not considered good practice. Furthermore, if there are no unit tests in place, it's a recipe for disaster.

Test
```
forge test --match-contract IssueFourTest -vv
```

#### Contract
[Upgradable.sol](src/Issue4/Upgradable.sol)

#### Link Reference
[Read The Issue#4 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-4-222bfdad66ec)


---
### Issue 5 - Usage of an incorrect version of Ownable library for Upgradable contracts

Summary

A regular, non-upgradeable Ownable library will make the deployer the default owner in the constructor. Due to a requirement of the proxy-based upgradeability system, no constructors can be used in upgradeable contracts. Therefore, there will be no owner when the contract is deployed as a proxy contract.

Test
```
forge test --match-contract IssueFiveTest -vv
```

#### Contract
[SafeOwner.sol](src/Issue5/SafeOwner.sol)

#### Link Reference
[Read The Issue#5 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-5-c4a47c3e042a)

[Link to Report](https://github.com/UNSNARL/audit-reports/blob/main/Dropzone_Komet_Security_Assessment.pdf)
