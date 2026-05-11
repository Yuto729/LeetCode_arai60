## Step1
You are a professional robber planning to rob houses along a street. Each house has a certain amount of money stashed. All houses at this place are arranged in a circle. That means the first house is the neighbor of the last one. Meanwhile, adjacent houses have a security system connected, and it will automatically contact the police if two adjacent houses were broken into on the same night.

Given an integer array nums representing the amount of money of each house, return the maximum amount of money you can rob tonight without alerting the police.

 

Example 1:
Input: nums = [2,3,2]
Output: 3
Explanation: You cannot rob house 1 (money = 2) and then rob house 3 (money = 2), because they are adjacent houses.

Example 2:
Input: nums = [1,2,3,1]
Output: 4
Explanation: Rob house 1 (money = 1) and then rob house 3 (money = 3).
Total amount you can rob = 1 + 3 = 4.

Example 3:
Input: nums = [1,2,3]
Output: 3
 
Example 4:
Input: nums = [2,1,1,2]
Output: 3

Constraints:
- 1 <= nums.length <= 100
- 0 <= nums[i] <= 1000

Approach
例を元に色々考えてみて以下を思いついた
- nums[0]が盗まれるとすると、nums[-1]は盗まれない。逆もなりたつので、先頭を除いたnumsと末尾を除いたnumsで最大値を計算し、２つの最大を取ればできそう

時間計算量: O(n)
空間計算量: O(1)
Accept
```py
class Solution:
    def rob(self, nums: List[int]) -> int:
        if not nums:
            return 0

        if len(nums) == 1:
            return nums[0]

        def rob_simple(nums):
            if not nums:
                return 0
            
            skipped_last = 0
            robbed_last = 0
            for i in range(len(nums)):
                skipped_last, robbed_last = max(skipped_last, robbed_last), skipped_last + nums[i]
            
            return max(skipped_last, robbed_last)
        
        return max(rob_simple(nums[1:]), rob_simple(nums[:- 1]))
```
- あまり考えないで書いたので`rob_simple`になっているが、`rob_section`, `rob_partial`とかのほうが良さそう
- rob_simpleはスライスじゃなくてインデックスを引数にするとメモリが節約できそう

## Step2 他の人のコードやコメントを見る

### 「余分な制約を1つ特定して、場合分けで消す」

- https://github.com/TakayaShirai/leetcode_practice/pull/35/changes

> 1. **円環の厄介さを特定する**: 直線のHouse Robberは解ける。円環で何が変わるかというと、「最初と最後が隣り合っている」という制約が**1つ増えただけ**。
> 2. **その制約を消せないか考える**: 厄介な制約が1つだけなら、**場合分けで消せることが多い**。最初の家を「盗む」か「盗まない」かで分ければ、最後の家との関係が確定する。
> 3. **場合分けしたら既知の問題に帰着するか確認する**: どちらの場合も、最初と最後のつながりが消えて直線になる。直線版はもう解けるので、それを2回使えば終わり。

また、「未知のものは何か」「与えられているものは何か」「**条件は何か**」を意識し、その条件を取り除く方法を考える

### DP（全列挙）からの状態圧縮として見る

- https://github.com/TakayaShirai/leetcode_practice/pull/35/changes

> 2^n通り列挙して、条件を満たさないもの・最大になりえないものを捨てていく。残るのは「1軒目で盗んだか盗んでいないか × 直前の家で盗んだか盗んでいないか」の4種類だけ。

🤖 ----------------------------------------------------------------------
**なぜ2種類（2変数）に落ちるか**
`nums = [1, 2, 3, 1]` の直線版で考える。

**Step1: 隣接違反パターンを捨てる**  
それぞれについて、盗むか盗まないか（1, 0）として16パターン列挙する
16通りのうち `11` を含むもの（隣接2軒を盗むパターン）をすべて削除。

**Step2: 最大になりようがないものを捨てる**  
3軒目の家の前に立ったとき、残っているパターンを「直前(2軒目)を盗んだか否か」で分類する：

| 直前の状態 | パターン例 | 累計 |
|---|---|---|
| 盗んだ (1) | `010?` | 2 |
| 盗まなかった (0) | `100?` | 1 |
| 盗まなかった (0) | `000?` | 0 ← **捨てられる** |

`000?` と `100?` は「直前を盗まなかった」という点で同じ。3軒目以降に影響するのは累計金額だけなので、累計が小さい `000?` は最大になりようがなく捨てられる。

**結果**: 各ステップで残るのは「直前を盗んだ場合の最大累計」「直前を盗まなかった場合の最大累計」の2つだけ。これが2変数DPそのもの：

```python
skipped_last, robbed_last = max(skipped_last, robbed_last), skipped_last + nums[i]
#              ↑直前を盗まなかった場合の最大              ↑直前を盗んだ場合の最大
```

円環制約があると「1軒目を盗んだかどうか」が最後まで影響するため、状態が `2 × 2 = 4` 種類に増える。それを避けるために `nums[:-1]` と `nums[1:]` に分けて2変数DPを2回走らせる構造になっている。
------------------------------------------------------------------------


### Tabulation vs Memoization（メモ化再帰）

- https://github.com/tom4649/Coding/pull/34/changes

| | Tabulation（反復型） | Memoization（再帰型） |
|--|--|--|
| 方向 | ボトムアップ | トップダウン |
| 実装 | for ループ | 再帰 + `@functools.cache` |
| メモリ | O(1) も可 | キャッシュ分必要 |

スライスをコピーせずインデックスだけ引き回す `rob_partial(begin, end)` 形式はメモリ効率が良い（https://github.com/mamo3gr/arai60/pull/34/changes）。