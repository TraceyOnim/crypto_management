# CryptoManagement

## Setting Up

To test the application in the development environment;
 - Create an account on [Etherscan](https://docs.etherscan.io/getting-started/creating-an-account) and generate an [API KEY](https://docs.etherscan.io/getting-started/viewing-api-usage-statistics)

 - The application will fetch the `API KEY` generated from the system therefore, create an `.env` file at the root of the application and add the following

  ```
  export  EtherScan_API_KEY=<replace this with your api>
  ```
  then run the command `source .env` on the terminal to export the `key` in the system environment.

NB: A `RuntimeError` will be raised in an attempt of starting the server before setting the `api_key`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Implementation Overview.

When a user visit the page `http://localhost:4000` they will see a form where they can enter a transaction hash:

![image](https://user-images.githubusercontent.com/43263401/188310332-008655a2-da99-479a-99a9-6f9e94072b46.png)


Once they submit the transaction hash, their request is sent to the server and the following process will take place:
 
 1. Validation
The transaction hash submitted will be validated to check if;
  - It already exist. Every transaction submitted must be unique
  - It is has a required length of minimum 64 and maximum 66.
     ```
     Example:
     valid hash with 0x prefix 7e2ac449ee8cc92362ca887633af7177699a98153f78033e4b572ee3ae485ec5 has a length of 64 with the 0x prefix its length 66

     ```

  - its not an empty hash 
Incase any of the criteria is not met, the user shall be notified.

2. Send request to Etherscan

If the validation has passed, a request is sent to Etherscan to fetch the transaction details. A transaction will be returned for a successful request. 

Incase of failed request, the user shall be notified that something went wrong.

3. Cache transaction locally

The transaction returned for successful request to Etherscan, is then cached locally using [Nebulex](https://hexdocs.pm/nebulex/Nebulex.Caching.html).

The transaction is cached locally to be used when scheduling job that involves updating pending transaction after a certain period. The cached transaction contains only pending transaction. If there is no  cached transaction the attempt to update transaction status to `complete` will be skipped hence avoiding making trips to the database after every specified period to fetch pending transactions and update them .And also avoid sending request to etherscan to fetch the recent block number(which is used for finding the number of confirmed blocks).

4. Persist to database
Once the above processes(validation, fetching from etherscan , caching locally) are successful meaning the is no error returned, the transaction is persisted into the database on the `transactions table`.

The user will see a confirmation message `Transaction created successfully` and also the transaction details displayed.

 ![image](https://user-images.githubusercontent.com/43263401/188310538-6ac7949d-5a9f-42cf-9aeb-81a4c933d6e3.png)


 5. Scheduler
 The scheduler server is responsible for updating confirmed transactions(pending transactions whose block confirmation number is >= 2) status to `complete` after every `20 seconds`.

 6. Broadcast updates
After the pending transactions have been updated, updates are broadcasted to provide live update of the current status.



## Dependencies Added
-  `HTTPoison` http client for Elixir to issue http request
    ```elixir
   def deps do
    [
      {:httpoison, "~> 1.8"}
    ]
   end
    ```

- `poison` for encoding and decoding `JSON` objects.

    ```elixir
    def deps do
      [{:poison, "~> 5.0"}]
    end
    ```

- `mox` to mock external request when testing.

   ```elixir
   def deps do
    {:mox, "~> 1.0", only: :test}
   end
   ```

- `nebulex` to cache transactions locally

   
   ```elixir
   def deps do
      {:nebulex, "~> 2.4"}
   end
