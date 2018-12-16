# Bitcoin Simulator
## Contributors:
* [Ankit Soni- 8761-9158](http://github.com/ankitprahladsoni)
* [Kumar Kunal- 5100-5964](http://github.com/kunal4892)


The project covers the implementation of all the Bitcoin protocols that
are necessary to mine, send and keep a balance. The features are discussed in details below:

`1. Mine bitcoins and earn money(coinbase transaction) by validating n previous transactions (solving a        difficult hash matching problem):`
   
   We define block and blockchain structure and provide methods to add new blocks to the blockchain with data. Proof of work, Difficulty, nonce is implemented(difficult to solve, but easy to verify). Difficulty is kept to 4 zeroes "0000" as a prefix in the calcluated hash. Consensus of difficulty is implemented. It can be changed (increased/decreased) at regular intervals based on the time current miners are taking to solve the present difficulty problem. Underlying datastructures like the transactionPool that collect transactions are updated(reset). Mining accomplishes certifying that the transactions are legitimate.

   *Result: Miner gets 50 bit coins for mining and the transaction pool is empited and a new block is added to the chain.*

`2. Send bitcoins as transactions to other peers (public addresses):`
   
   Underlying datastructures for Transactions(id, TxIns[] and TxOuts), Blockchain, TransactionPool 
   are implemented to make transactions between peers possible.
   Underlying datastructure transactionPool that colelcts transactions is added with a new entry of the current transaction.
   When a peer sends some currency to others, it refers to another datastructure called as UnspentTransactionOuts(covered more in wallet), to find out the exact amount the user has. This amount can be transferred. The transfer works by breaking the n UnspentTransactionOuts Into TransactionIns[] and TransactionOuts[]. TransactionOuts[] bind the currency to the recieving peer's address and the remaining change amount with it's own addres. TransactionIns[] contain the data that supplement verification by any party/server that needs to verify whether the transaction is legitimate and not malicious.

   *Result:  Datastructrures transactionPool is updated with a new entry.*
   *UnspentTransactionOuts entries are broken down into two datastructures  TransactionOuts[] and* TransactionIns[].*

`3. Maintain wallets for all Peers in the network by using private-public key encryption schemes:`
   
   Using Public-key cryptography and signing and verifying signatures is implemented.
   Creating a new wallet is possible. Viewing the balance of one's wallet and Sending coins to other addresses is also possible.
   UnspentTransactionsOuts datastructure is implemented to find out the given balance of a peer's wallet
   at any given point in time by quering and filtering  all UnspentTxouts by it own public address.
   Wallets need to store the encrypted keys in the file system, but file lookups makes this a slow process.
   The keys are not stored persistently.
   It is possible to look at the public keys and find out the net balance of any peer with a certain public key. Ofcourse the privacy is not compromised as these addresses don't reveal identity.

   *Result:  Wallet Balance for peers*

`4. Transaction Validation is elaborately implemented:`

   For each transaction to be added to the pool of transactions, we make sure that the transactions added to the pool is in conformance and that no malicious transaction was slipped in the list of transaction.
   The pool of transactions are taken and clubbed together as blockData of a Block for the probable next block that will be mined and added to the Blockchain.
   Coinbase transactions or sending money to oneself and mining is implemented and also covered in the testing. Please refer to the test cases for more information as there are numerous cases to consider and each of them are handled and tested.
   
   *Result: Malicious/Incorrect transactions are not added to the list of transaction(Tx Pool)*

`5. Block and BlockChain Validation:`

   Before the Blockchain is updated, a block's own id and it's BlockData(Transactions) need to be verified.
   The information that the problem was solved by a miner(hash and monce) is stored in the prospective block. This information is verified by all peers/ the server before adding the block to their own chain. Similarly the entire chain can also be verified one block at a time, and the fact that each block maintains the hash of the previous block makes it impossible for the blocks to be modified.
   With this implementation, replacing the entire blockchain by a malicious peer is also averted, since each peer keeps maintains a local blockchain in it's own state.

   *Result: Malicious/Invalid blocks are not added to the chain*

`6. Web interface using Phoenix is implented for the running the simulation. The visualization is done using javascript library for charts(chart.js)`

  Publish-Subscribe paradigm over channels is used to form a two way channel between the Phoenix application and the elixir code running in the backend. The Server-genserver subscribes to a topic on the channel. Phoenix provides websockets for communication. These sockets also join the channel.
  When the Phoneix application is started using the "Start Proces" button, an event is broadcasted with the subscribed topic on the channel. This is the request for the genserver to start 100 peers/genservers to start mining and after a delay, send a part of the earned bitcoin to other peers. This keeps the network churning.

  *Result: The results can be seen in the form of line graph(No of bicoins mined) and Radar graph( Wallet Balance for Each Peer)*

`7. For test cases, please refer to Project 4.1. We have a list of 37 test cases that test each  functionality listed above. It also unit tests each function. With the previous submission, you can also find the pdf file in the comments that explains all the test cases in addition to meaningful names.`


To start the Phoenix server:
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
Push the Start Process button and Voila!!

