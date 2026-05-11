You are given an integer array coins representing coins of different denominations and an integer amount representing a total amount of money.
Return the fewest number of coins that you need to make up that amount. If that amount of money cannot be made up by any combination of the coins, return -1.
You may assume that you have an infinite number of each kind of coin.

Example 1:
Input: coins = [1,2,5], amount = 11
Output: 3
Explanation: 11 = 5 + 5 + 1

Example 2:
Input: coins = [2], amount = 3
Output: -1

Example 3:
Input: coins = [1], amount = 0
Output: 0
 
Example 4:
Input: coins = [1,2,5,10], amount = 11
Output: 2

Constraints:
- 1 <= coins.length <= 12
- 1 <= coins[i] <= 2^31 - 1
- 0 <= amount <= 10^4
制約なしナップサック問題っぽい？

Approach
- dp[i][j] -> i番目までのコインを使って合計値jを構成するときの最小の枚数
- 更新則 -> dp[i][j] = min(dp[i-1][j], dp[i][j-coins[i]])
- i番目までのコインを使って合計値jを構成する -> i番目を使わずに構成する or i番目を少なくとも1枚使って構成する

26分ほどかかった
詰まった点
- `-1`を返さないといけないケースで条件分岐が抜けていてnullがかえってしまった
- in: [1], 10のようなケースで初期化がうまくできていなかった。`if coins[0] == j`と書いてしまっていた
- dpの更新則でi番目のコインを少なくとも１枚含むときに、+1をするのを忘れていた
- 初期化の行と列（amount + 1とlen(coins)）が逆にしていた

時間計算量 -> O(amount * n)
空間計算量 -> ,,
```py
class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        dp = [[float('inf')] * (amount + 1) for _ in range(len(coins))]
        for i in range(len(coins)):
            dp[i][0] = 0
        for j in range(1, amount + 1):
            # 注意
            if j % coins[0] == 0:
                dp[0][j] = j // coins[0]

        for i in range(1, len(coins)):
            for j in range(1, amount + 1):
                if j < coins[i]:
                    dp[i][j] = dp[i - 1][j]
                    continue

                dp[i][j] = min(dp[i - 1][j], dp[i][j - coins[i]] + 1)

        if dp[len(coins) - 1][amount] == float('inf'):
            return -1
        
        return dp[len(coins) - 1][amount]
```

🤖
- 空間計算量をO(amount)にできる
```py
class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        dp = [float('inf')] * (amount + 1)
        dp[0] = 0
        for coin in coins:
            for j in range(coin, amount + 1):
                dp[j] = min(dp[j], dp[j - coin] + 1)

        if dp[amount] == float('inf'):
            return -1
        
        return dp[amount]
```
- 各if文をループで完結するようにすると以下のようになる
```py
class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        n = len(coins)
        dp = [[float('inf')] * (amount + 1) for _ in range(n)]

        for i in range(n):
            dp[i][0] = 0

        for j in range(coins[0], amount + 1, coins[0]):
            dp[0][j] = j // coins[0]

        for i in range(1, n):
            for j in range(1, amount + 1):
                dp[i][j] = dp[i - 1][j]
            for j in range(coins[i], amount + 1):
                dp[i][j] = min(dp[i][j], dp[i][j - coins[i]] + 1)

        return -1 if dp[n - 1][amount] == float('inf') else dp[n -
1][amount]

```
-`float('inf')`との比較を最後にやっているのが不自然だと感じたので改善案を聞いてみる
    - 番兵値を`INF = amount + 1`にして最後の場合分けを`dp[amount] < INF`にする
    - floatじゃなくてintなのでやや自然
    - `UNREACHABLE`とかのほうがいいかも

- より速い回答 -> BFSがあるらしい
### 変数名や可読性の観点
- ループ変数jはインデックスなのか金額なのかわからないので`current_amount`とかのほうが良い
- `dp` -> `min_coins_using[i][j]`, `min_coins_for[j]`とかにすると良さそう
    - 適宜コメントで補いたい ex. minimum number of coins to make up amount j using first i+1 coins

### follow up
- coinの種類が動的に追加される場合 -> 1DのDPなら差分だけをイテレーションして追加することができる
- 組み合わせを返す問題 -> 各jにおいて最後に使ったコインを記録する(組み合わせを１つ返すことが可能)
```py
class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        dp = [float('inf')] * (amount + 1)
        dp[0] = 0
        last_coins_used = [-1] * (amount + 1)
        for coin in coins:
            for j in range(coin, amount + 1):
                if d[j - coin] + 1 < dp[j]:
                    dp[j] = dp[j - coin] + 1
                    last_coin_used[j] = coin
                
        combination = []
        j = amount
        while j > 0:
            coin = last_coin_used[j]
            combination.append(coin)
            j -= coin
        
        return combination
```
- 組み合わせの総数を返す
- 使用枚数に上限がある
- amountが非常に大きい場合

## Step3
```py
class Solution:
    def coinChange(self, coins: List[int], amount: int) -> int:
        n = len(coins)
        min_coins_using_for = [float('inf')] * (amount + 1)
        min_coins_using_for[0] = 0
        for coin in coins:
            for current_amount in range(amount + 1):
                if current_amount < coin:
                    continue

                min_coins_using_for[current_amount] = min(min_coins_using_for[current_amount], min_coins_using_for[current_amount - coin] + 1)
        
        if min_coins_using_for[amount] == float('inf'):
            return -1

        return min_coins_using_for[amount]
```