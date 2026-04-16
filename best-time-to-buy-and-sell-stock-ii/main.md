## Step1
You are given an integer array prices where prices[i] is the price of a given stock on the ith day.
On each day, you may decide to buy and/or sell the stock. You can only hold at most one share of the stock at any time. However, you can sell and buy the stock multiple times on the same day, ensuring you never hold more than one share of the stock.

Find and return the maximum profit you can achieve.

 
Example 1:
Input: prices = [7,1,5,3,6,4]
Output: 7
Explanation: Buy on day 2 (price = 1) and sell on day 3 (price = 5), profit = 5-1 = 4.
Then buy on day 4 (price = 3) and sell on day 5 (price = 6), profit = 6-3 = 3.
Total profit is 4 + 3 = 7.

Example 2:
Input: prices = [1,2,3,4,5]
Output: 4
Explanation: Buy on day 1 (price = 1) and sell on day 5 (price = 5), profit = 5-1 = 4.
Total profit is 4.

Example 3:
Input: prices = [7,6,4,3,1]
Output: 0
Explanation: There is no way to make a positive profit, so we never buy the stock to achieve the maximum profit of 0.
 

Constraints:
- 1 <= prices.length <= 3 * 10^4
- 0 <= prices[i] <= 10^4

Approach
複雑に考えて思いつかなかったので解法をAIに教えてもらう
- 底で買って、天井で売ることを繰り返すだけ（当たり前だけど思いつかない）
- 天井の判定はprices[i-1] < prices[i] < prices[i+1]のとき、prices[i]と, 買ったときの差分が利益になる    
-> 前の価格との差分がプラスのときは差分を足せば良い
**条件判定を差分の積み上げに変換する**

時間計算量: O(n)
空間計算量: O(1)
以下を実装し、Accept
```py
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        if not prices:
            return 0

        prev_price = prices[0]
        total_benefit = 0
        for i in range(1, len(prices)):
            total_benefit += max(prices[i] - prev_price, 0)
            prev_price = prices[i]
        
        return total_benefit
```

他の解法
- 状態 ✕ 行動で解けそうな気がした
    - 状態空間 S = {hold, cash}, 行動空間 A = {buy, sell, stay}, 
    - 状態遷移
     (hold, sell) -> cash, (hold, stay) -> hold, (cash, buy) -> hold, (cash, stay) -> cash

- pricesを走査する過程で、状態Sのときの最大利益をそれぞれ保持する
- i日目のとき、i-1日目のときのSとAの組み合わせからi日目にSであるときの最大値を更新する
- 各日の最大利益は直前の状態にのみ依存する（マルコフ性）ため、逐次更新で最大利益が得られる

```py
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        if not prices:
            return 0
        
        max_profit_case_hold = -prices[0]
        max_profit_case_cash = 0
        for i in range(1, len(prices)):
            max_profit_case_hold, max_profit_case_cash = max(max_profit_case_hold, max_profit_case_cash - prices[i]), max(max_profit_case_cash, max_profit_case_hold + prices[i])
        
        return max(max_profit_case_hold, max_profit_case_cash)
```

- 最終日にS = holdのまま終わるのは損なので、最後は`return max_profit_case_cash`でいい

## Step2 他の人のコード・コメントを読む

**同時更新 vs 逐次更新のトレードオフ**
[nittoco PR#44](https://github.com/nittoco/leetcode/pull/44#discussion_r1875358734)
> 以下のコードでも通るっぽい。簡潔ではあるが、max(profit_not_having_stock, profit_having_stock + prices[i]) の時だけ profit_having_stock が実は同時点で、ただ前の行で更新されているならば -prices[i] と +prices[i] で打ち消しあって、前時点の profit_not_having_stock に結果的になる、という推理が必要？

→ Pythonのタプルアンパックで同時更新する方が意図が明確。逐次更新で通る場合は「なぜ通るか」の推理が読み手に要求される。

**変数名：hold/cash vs bottom/peak**
[goto-untrapped PR#59](https://github.com/goto-untrapped/Arai60/pull/59#discussion_r1782748689)
> `bottomPrice`, `peekPrice` としたらどうでしょうか？

→ Peak-Valley解法では `buy/sell` より `bottom/peak` の方がドメインを表現できる。ただし単調減少の末尾など「山でも谷でもない点」が生じる点は注意。

---

#### 別解など

**`itertools.pairwise` を使った関数型スタイル（Python 3.10+）**
[mamo3gr PR#36](https://github.com/mamo3gr/arai60/pull/36) より：
```python
import itertools

return sum(
    max(0, today - yesterday) for yesterday, today in itertools.pairwise(prices)
)
```
→ `range` + インデックスアクセスより意図が読みやすい。`pairwise` は隣接要素のペアを返すイテレータ。

Haskellで書くと対応関係が明確になる：
```haskell
maxProfit :: [Int] -> Int
maxProfit prices = sum . filter (> 0) $ zipWith (-) (tail prices) prices
```
`zip prices (tail prices)` が `pairwise` に相当。Haskellでは遅延評価なのでこのパターンが慣用句。

**Top-Down DP（メモ化再帰）**
[goto-untrapped PR#59](https://github.com/goto-untrapped/Arai60/pull/59) より：
```java
private int maxProfitHelper(int[] prices, int startIndex) {
    if (startIndex >= prices.length) return 0;
    if (memo[startIndex] > 0) return memo[startIndex];
    // startIndex以降で最大利益を再帰的に計算
}
```
→ メモなしだと O(2^n). メモありだとO(n^2)

- **Top-Down**：再帰で末端まで降りてから値を埋めながら戻る
```python
from functools import lru_cache

def maxProfit(prices):
    @lru_cache(maxsize=None)
    def dp(i):
        if i >= len(prices):
            return 0
        best = 0
        for j in range(i + 1, len(prices)):
            diff = prices[j] - prices[i]
            if diff > 0:
                best = max(best, diff + dp(j + 1))
        return best
    return dp(0)
```

- **Bottom-Up**：初期値から順に前方向へ適用
```python
def maxProfit(prices):
    hold, cash = -prices[0], 0
    for i in range(1, len(prices)):
        hold, cash = max(hold, cash - prices[i]), max(cash, hold + prices[i])
    return cash
```

---

#### その他

- [goto-untrapped PR#59](https://github.com/goto-untrapped/Arai60/pull/59#discussion_r1782748689) / [naoto-iwase PR#43](https://github.com/naoto-iwase/leetcode/pull/43#discussion_r1875358734) より：
> 毎日できることは、株を持っているか、お金を持っているかの2択なので、未来が見える人になったとして、どちらがいいかを考えればいいのです。

→ S = {hold, cash} の状態定義の本質をシンプルに言い表している。「未来が見える人」という前提がこの問題の核心。

- Peak-Valley はbottomから始める方が自然
[nittoco PR#44](https://github.com/nittoco/leetcode/pull/44) より：
> peakとbottomを交互にループするのは、最初にbottomをやった方が綺麗そう？気づかなかった。

→ 「谷を探す→山を探す→利益加算」の順がアルゴリズムの意図に即している。

### follow up
- 最大k回しか取引できない
状態空間をS ✕ K (k=1,2,3...k)に拡張する
```py
hold[k], cash[k] = max(hold[k], cash[k] - price), max(cash[k], hold[k] + price)
```
- 売った翌日は買えない -> S = {hold, cool, rest}に分割する。hold -> sell -> cool(翌日は買えない)
cool -> stay -> rest, rest -> buy -> hold, rest -> stay -> rest

## Step3
```py
class Solution:
    def maxProfit(self, prices: List[int]) -> int:
        if not prices:
            return 0
        
        max_profit_case_hold, max_profit_case_cash = -prices[0], 0
        for i in range(1, len(prices)):
            max_profit_case_hold, max_profit_case_cash = max(max_profit_case_hold, max_profit_case_cash - prices[i]), max(max_profit_case_cash, max_profit_case_hold + prices[i])
        
        return max_profit_case_cash
```