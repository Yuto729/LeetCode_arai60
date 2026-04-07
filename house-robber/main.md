## Step1
You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed, the only constraint stopping you from robbing each of them is that adjacent houses have security systems connected and **it will automatically contact the police if two adjacent houses were broken into on the same night.**

Given an integer array nums representing the amount of money of each house, return the maximum amount of money you can rob tonight without alerting the police.


Example 1:
Input: nums = [1,2,3,1]
Output: 4
Explanation: Rob house 1 (money = 1) and then rob house 3 (money = 3).
Total amount you can rob = 1 + 3 = 4.

Example 2:
Input: nums = [2,7,9,3,1]
Output: 12
Explanation: Rob house 1 (money = 2), rob house 3 (money = 9) and rob house 5 (money = 1).
Total amount you can rob = 2 + 9 + 1 = 12.
 
Constraints:
- 1 <= nums.length <= 100
- 0 <= nums[i] <= 400

つまり、1つ以上離れている要素の部分列を抽出したときのその部分列の和の最大値

Example 3:
in: nums = [1]
out: 1

Approach
- 樹形図を書くように探索する。
- 今いる位置から次に足せる候補は１つ以上離れている要素
- １つ以上離れているので貪欲法だと無理
- 一旦再帰で書いてみる
時間計算量: O(n^n/2)
```py
class Solution:
    def rob(self, nums: List[int]) -> int:
        if not nums:
            return 0
        
        if len(nums) == 1:
            return nums[0]
        # @cache
        def rob_helper(nums, money):
            nonlocal max_money
            if not nums:
                max_money = max(max_money, money)
                return
            
            if len(nums) == 1 or len(nums) == 2:
                max_money = max(max_money, money)
                return

            for i in range(2, len(nums)):
                rob_helper(nums[i:], money + nums[i])

        max_money = 0
        rob_helper(nums, nums[0])
        rob_helper(nums[1:], nums[1])
        return max_money
```

- @cacheがunhashableになってしまうのでインデックスで書き直す
- さらに@cacheが機能するように書き換える
    - 現在はキャッシュキーが(start, money)になるため、キャッシュが効かない
    - 最大値をグローバルに計算しているが、貪欲に「取る or スキップ」の２択に分解して最大値を返すようにすれば貪欲法で解ける

時間計算量
- @cacheなし => O(2^n)
- @cacheあり => O(n) (rob_helper(start)は、start = 0, 1, 2, ... nくらいしか状態がないのでそれぞれ一度だけ計算すればいいから)

空間計算量
- @cacheなし => 再帰の深さn
- @cacheあり => 再帰の深さ + キャッシュ = O(n)
```py
class Solution:
    def rob(self, nums: List[int]) -> int:
        if not nums:
            return 0
        
        if len(nums) == 1:
            return nums[0]
        @cache
        def rob_helper(start):
            if start >= len(nums):
                return 0

            rob_current = nums[start] + rob_helper(start + 2)
            skip_current = rob_helper(start + 1)

            return max(rob_current, skip_current)
        
        return rob_helper(0)
```

もっと効率の良いやり方を考える
- 貪欲法でできるとしたら、nums[i]で終わる部分列のうち、和が最大であるものをメモ化すれば良さそう
- return max(dp)で答えが出そう
- dp[i] = max(dp[:i-2]) + nums[i]
時間計算量: O(n^2)
空間計算量: O(n)

```py
class Solution:
    def rob(self, nums: List[int]) -> int:
        if not nums:
            return 0

        if len(nums) == 1:
            return nums[0]
        
        if len(nums) == 2:
            return max(nums[0], nums[1])

        total_money = [0] * len(nums) # 要素は0以上なので
        total_money[0] = nums[0]
        total_money[1] = nums[1]
        for i in range(2, len(nums)):
            # total_money[i - 1]のインデックスを間違えないように
            total_money[i] = max(total_money[:i - 1]) + nums[i]
        
        return max(total_money)
```

- 🤖上記コードはさらに改善できる（時間計算量: O(n), 空間計算量: O(1)）
step by stepで改善する. まずは時間計算量について
```py
class Solution:
    def rob(self, nums: List[int]) -> int:
        if not nums:
            return 0

        if len(nums) == 1:
            return nums[0]
        
        if len(nums) == 2:
            return max(nums[0], nums[1])

        total_money = [0] * len(nums) # 要素は0以上なので
        total_money[0] = nums[0]
        total_money[1] = nums[1]
        best_up_to_prev = nums[0]
        for i in range(2, len(nums)):
            # previous_max: total_money[i - 2]までの最大値を保持する
            total_money[i] = best_up_to_prev + nums[i]
            best_up_to_prev = max(best_up_to_prev, total_money[i - 1]) # 最大値を更新(total_money[i - 1]までの最大になる)
        return max(total_money)
```
空間計算量をO(1)にする
- 答えとなる最大値を変数で保持する
- total_money[i - 1]を変数で保持する
```py
class Solution:
    def rob(self, nums: List[int]) -> int:
        if not nums:
            return 0

        if len(nums) == 1:
            return nums[0]
        
        if len(nums) == 2:
            return max(nums[0], nums[1])

        best_up_to_prev = nums[0]
        best_up_to_current = max(nums[0], nums[1]) # max_moneyは逐次更新するので、i=0,1について先に最大値を計算しないとぬけもれが発生する。ex. [1,3,1]
        previous_total_money = nums[1]
        for i in range(2, len(nums)):
            total_money = best_up_to_prev + nums[i]
            best_up_to_prev = max(best_up_to_prev, previous_total_money)
            best_up_to_current = max(best_up_to_current, total_money)
            previous_total_money = total_money

        return best_up_to_current
```
- indexのスタートを1からにしても良さそう
以下のようになる
```py
        best_up_to_prev = 0
        best_up_to_current = nums[0]
        previous_total_money = nums[0]
        for i in range(1, len(nums)):
```

## Step2

### 他の解法・コメントまとめ

#### 1. 再帰の計算量はフィボナッチ数列になる

> robHelper(100) と呼ぶと、robHelper(99) と robHelper(98) が呼ばれて、再帰的に木ができあがりますね。（中略）請求書の数をbill(n)という関数で表すと、bill(100) = bill(99) + bill(98) になり、bill(1) = bill(0) = 1 より、フィボナッチ数列からbill(100) ≒ 1.6^100

([oda, hroc135 #33](https://github.com/hroc135/leetcode/pull/33))

メモなし再帰の計算量を O(2^n) と思いがちだが、正確には O(φ^n)（φ≒1.618、黄金比）。完全二分木ではなく、葉の数がフィボナッチ数列の漸化式 `f(n) = f(n-1) + f(n-2)` に従うため。

#### 2. 変数名 `robbedLast` / `skippedLast`

([nittoco, hroc135 #33](https://github.com/hroc135/leetcode/pull/33))

`twoBefore`, `oneBefore` などのインデックスベースの変数名より、**「直前の家を盗んだか・盗まなかったか」という状態**を表す変数名の方が、DPの意図が伝わりやすい。

```go
skippedLast := 0
robbedLast := nums[0]
for i := 1; i < len(nums); i++ {
    skippedLast, robbedLast = max(skippedLast, robbedLast), skippedLast+nums[i]
}
return max(skippedLast, robbedLast)
```

これは「各家の前に手下を一人ずつ立たせて、前から2つの伝言（最大いくら取れるか、目の前の家を盗まない場合の最大）を渡す」という直感と対応している。

#### 3. ループ末尾で max を取る必要はない

([oda, Yoshiki-Iwasa #50](https://github.com/Yoshiki-Iwasa/Arai60/pull/50))

ループの外で `max(total_money)` を取るのではなく、**ループ内で `oneBefore` を常に「ここまでの最大値」として更新**すれば、最後の値をそのまま返せる。

#### 4. 再帰上限に注意

([TORUS0818 #33](https://github.com/hroc135/leetcode/pull/33))

Pythonのデフォルト再帰上限は1000。`sys.setrecursionlimit()` で変更可能だが、本番コードでは注意が必要。`n <= 100` の本問題では問題ないが、大きい入力に備えるなら反復DPの方が安全。

### 発想
- https://github.com/Yoshiki-Iwasa/Arai60/pull/50/changes#r1717915563
>なんとなく、発想が不自然な気がしています。
各家の前に、泥棒の手下が一人ずつ立って、前から伝言をもらって、最後のところで求めたい数字を知りたいとします。
「伝言」の内容は「ここまで最大いくら取れる、俺の眼の前の家に盗みに入らないとすると最大いくら取れる」の二つだけじゃないですか。

目の前の家を盗みに入るかどうかを考えるとき、ここまで取れる最大値と目の前の家に盗みに入らないとすると最大どれくらい取れるかから、盗むかスキップするかを選択するはず


### スレッドセーフ
- https://github.com/Mike0121/LeetCode/pull/47#discussion_r1799964450
> functools.lru_cacheを確認しておいて欲しいのと、inner function は定義するたびにオブジェクトとして作り直されていることを確認して欲しいです。
このコードはスレッドセーフティーという意味でどうなっているでしょうか。

inner functionのローカル変数はスレッドセーフ

- https://github.com/naoto-iwase/leetcode/pull/40/changes#r2478789419
> これは、一箇所やったら通らなくなるくらい重いと思います。
グローバル変数の濫用について。常にプロダクションを意識したい


## Step3
- Step1の最後の回答と本質的には同じ
```py
class Solution:
    def rob(self, nums: List[int]) -> int:
        if not nums:
            return 0
            
        skipped_last = 0
        robbed_last = nums[0]
        for i in range(1, len(nums)):
            skipped_last, robbed_last = max(skipped_last, robbed_last), skipped_last + nums[i]
        
        return max(skipped_last, robbed_last)
```