# Tasks:

## 1. Understand the Industry

### 1.1. Explain the money flow and the information flow in the acquirer market and the role of the main players.

An acquirer is the entity responsible for processing debit and credit card transactions on behalf of a seller. In this scenario, It sits between the buyer and the seller allowing easier and more secure transactions using strict standards like PCI DSS. This type of institution must not be confused with the issuer institution, responsible for actually issuing cards to their final clients (buyers) via a card network (e.g. Visa). My main issue about this topic is who should be accountable for detecting fraud, for example. Do these entities perform the same anti-fraud "checklist"? What happens when their evaluation of a transaction diverges?

### 1.2. Explain the difference between acquirer, sub-acquirer and payment gateway and how the flow explained in question 1 changes for these players.

Thank you for the opportunity to learn more about these confusing terms! I always understood the gateway institutions being the same as the acquiring institutions. They are not! Gateways are responsible for getting payment information from buyers and sending them to acquiring institutions. The sub-acquirer, in my understanding, sits between the acquirer entity and the seller. I must say I am confused about the concepts of gateway and sub-acquirer (maybe because some companies play both roles?). The payment process could be summarized with the following: buyer => gateway => acquirer => (sub-acquirer here?) => card network => card issuer => seller.

### 1.3. Explain what chargebacks are, how they differ from cancellations and what is their connection with fraud in the acquiring world.

Chargebacks are (mostly) a buyer's option. They can request one directly from the card issuer institution if they do not recognize the transaction. Fraud-detection systems can also charge back transactions, but, for me, it is not clear who (buyer, gateway, acquirer, etc) should be held accountable for paying (refunding?) fees in the transaction process. Maybe this represents the difference between transaction cancellations, where funds have not (yet) left the buyer's account, even if they are shown in their account statement for a short period. I guess that in the acquirer setting, the cancellation of transactions by the acquirer when a fraud is detected early in the transaction process (for example), is good for all entities involved, especially because there will be no refunds from any of them, and no contests (probably) from anyone but the buyer.

## 2. Get your hands dirty

It is difficult to assess each transaction individually, so first, I would put the transactions into context by grouping them by merchant_id/user_id/card_number (the entities involved), generating three different sets of groups. For each set, I would calculate the average/standard deviation of the number and amount of its transactions and suspect transactions with a number/amount above/less their average plus/less its standard deviation. To be less restrictive, considering that most transactions are legit (Does Pareto's principle apply in this setting?), I could suspect only transactions above/less than three times its group's standard deviation, since this would classify most transactions around the average as legit, considering the number of transactions and their amounts as variables that follow normal distributions. Of course, we could use more data to access the transactions. For example, the IDs of the entities involved in the transaction process (gateway, acquirer, etc). It is not common, but It may be possible that there could be some "Man-in-the-Middle" frauds.

## 3. Solve the problem

Please, refer to the other files in this repository.
