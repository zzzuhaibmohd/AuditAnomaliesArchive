## Audit Anomalies Archive

This repository is designed to maintain a record of unique and fundamental vulnerabilities I discover during my smart contract audits. All the issues documented here have been reproduced using Foundry.

Inspired from SunSec(https://twitter.com/1nf0s3cpt)

## List of Issues
[20230814 Issue#1](#issue-1---denial-of-servicedos-due-to-hardcoding-of-decimals)

[20230816 Issue#2](#issue-2---users-losing-funds-due-to-missing-functionality-to-refund-extra-ether-sent)

[20230826 Issue#3](#issue-3---skipping-the-payment-of-platform_fee-because-of-user-controlled-input-parameters)

[20230908 Issue#4](#issue-4---custom-upgradable-contract-leading-to-double-initialization)

[20230914 Issue#5](#issue-5---usage-of-an-incorrect-version-of-ownable-library-for-upgradable-contracts)

[20231009 Issue#6](#issue-6---immutable-address-causing-dos-due-to-blacklist-or-private-key-compromise)

[20231114 Issue#7](#issue-7---use-of-selfdestruct-leading-to-denial-of-service-of-functions-of-the-bridge-contract)

[20231123 Issue#8](#issue-8---not-following-cei-pattern-leads-to-cross-function-re-entrancy)

[20231219 Issue#9](#issue-9---denial-of-servicedos-of-users-due-to-inconsistent-implementation-of-pausable-pattern)

[20240210 Issue#10](#issue-10---loss-of-user-deposited-funds-due-to-missing-array-length-input-validation)

[20240412 Issue#11](#issue-10---loss-of-user-deposited-funds-due-to-missing-array-length-input-validation)

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

---
### Issue 6 - Immutable address causing DoS due to Blacklist or Private Key Compromise

Summary

Declaring an address as immutable in a smart contract can lead to issues, especially when the address serves vital functions like fee collection. The presence of blacklisting capabilities in tokens or private key compromise can disrupt protocol operations, making it essential for developers and auditors to assess these scenarios carefully.

Test
```
forge test --match-contract IssueSixTest -vv
```

#### Contract
[BlackList.sol](src/Issue6/BlackList.sol)

#### Link Reference
[Read The Issue#6 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-6-b6ed431e82b7)

[Link to Report](https://www.codehawks.com/report/cllcnja1h0001lc08z7w0orxx#M-02)

---
### Issue 7 - Use of selfdestruct leading to Denial of Service of functions of the Bridge contract

Summary

When transfering native token balances (For Example: ETH), ensure proper tracking for each user. In EVM-compatible chains, native tokens can be forcefully sent to the contract via selfdestruct. If not handled promptly, this situation may result in contract malfunction, causing a Denial of Service (DoS) in our example.

Test
```
forge test --match-contract IssueSevenTest -vv
```

#### Contract
[TestBridge.sol](src/Issue7/TestBridge.sol)

#### Link Reference
[Read The Issue#7 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-7-1728d9fef43a)

---
### Issue 8 - Not Following CEI pattern leads to cross-function re-entrancy

Summary

The issue revolves around the misconception that ReentrancyGuard alone is sufficient for preventing reentrancy vulnerabilities in smart contracts. It's evident that developers often overlook the importance of following the Checks-Effects-Interactions pattern, leading to potential exploits. In a specific example with a token bridge protocol, this flaw allows an attacker to manipulate the withdrawal process, exploiting a missed adherence to the CEI pattern and resulting in cross-function re-entrancy.

Test
```
forge test --match-contract IssueEightTest -vv
```

#### Contract
[TestBridge.sol](src/Issue8/TestBridge.sol)

#### Link Reference
[Read The Issue#8 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-8-c574ffa4f439)


---
### Issue 9 - Denial of Service(DoS) of users due to inconsistent implementation of Pausable pattern

Summary

Smart contracts employ the pausable pattern to facilitate emergency halts, enabling developers to pause contracts during migrations, upgrades, or potential security threats. However, potential issues arise when different contracts inconsistently implement the pausable pattern, impacting users during emergencies, emphasizing the need for a unified pausing mechanism across multiple contracts to maintain consistency and prevent disruptions in critical scenarios.

Test
```
forge test --match-contract IssueNineTest -vv
```

#### Contract
[PauseMePlease.sol](src/Issue9/PauseMePlease.sol)

#### Link Reference
[Read The Issue#9 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-9-c9e6c1a53ea3)

---
### Issue 10 - Loss of user deposited funds due to missing array length input validation

Summary
If there are functions that can be called by users and accept input parameters, it is always a good practice to validate these inputs for length, size, data type, etc. Skipping to do so can result in unexpected behavior. One such impact in this case was be users losing their deposited funds.

Test
```
forge test --match-contract IssueTenTest -vv
```

#### Contract
[SplitTheNFT.sol](src/Issue10/SplitTheNFT.sol)

#### Link Reference
[Read The Issue#10 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-10-c3373196923e)

---
### Issue 11 - Tokens stuck in the contract during migration forever as a result of user behaviour

Summary
Besides approaching problems from a developer/auditor mindset, it's essential to occasionally analyze and consider things from a user perspective. In essence, the assumption underlying the issues is: what if the user doesn't take a certain action, such as token migration?

#### Contract
[CoinSwitch.sol](src/Issue11/CoinSwitch.sol)

#### Link Reference
[Read The Issue#11 Blog](https://zuhaibmd.medium.com/audit-anomalies-archive-issue-11-7e6f4d423663)

