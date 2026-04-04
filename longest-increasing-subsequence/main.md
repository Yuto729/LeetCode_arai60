## Step1
Given an integer array nums, return the length of the longest strictly increasing

Example 1:
Input: nums = [10,9,2,5,3,7,101,18]
Output: 4
Explanation: The longest increasing subsequence is [2,3,7,101], therefore the length is 4.

Example 2:
Input: nums = [0,1,0,3,2,3]
Output: 4
[0,1,2,3]

Example 3:
Input: nums = [7,7,7,7,7,7,7]
Output: 1

Example 4:
Input: nums = [1,5,-2,1,4,3,5]
Output: 4
[-2,1,4,5], [-2,1,3,5]

Constraints:
1 <= nums.length <= 2500
-10^4 <= nums[i] <= 10^4

Follow up: Can you come up with an algorithm that runs in O(n log(n)) time complexity?

似たような問題をやったことがあるので解き方を思い出す
- numsを前から順に走査する。iの位置にいるとき、それ以降を走査してnums[i]より大きい位置をjとするとjを末尾とするLISの長さはmax(iを末尾とするLISの長さ + 1, jを末尾とする現時点でのLISの長さ)
- 上記の更新即が得られるのでDPテーブルを次のように定義. dp[i]: 位置iを末尾とするLISの長さ
- 時間計算量: O(N^2)
- 空間計算量: O(N)

以下のように解いたが、実行時間が遅い方の山だった
```py
class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:
        n = len(nums)
        len_lis = [1] * n
        for i in range(n):
            for j in range(i + 1, n):
                if nums[j] <= nums[i]:
                    continue
                
                len_lis[j] = max(len_lis[i] + 1, len_lis[j])
        return max(len_lis)
```
以下でも同じ
```py
class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:
        n = len(nums)
        len_lis = [1] * n
        for i in range(n):
            for j in range(i):
                if nums[j] >= nums[i]:
                    continue

                len_lis[i] = max(len_lis[j] + 1, len_lis[i])
                
        return max(len_lis)
```

🤖 AI review
- 制約上numsの長さは1以上だが、空リストが入力されると問題が起きるので`if not nums`でearly returnするほうが良さそう
- dpテーブルの命名 => `lis_lengths`, `lis_len_ending_at`など

### Follow up考えてみる
O(nlogn)ということは外側のループはそのままで内側のループの計算量をlog(n)にすれば良い。log(n)といえば二分探索でjを見つけることが考えられる。二分探索を使えるようにdpテーブルを構築する
改めて`j`とは、
- 自分(`nums[i]`)より小さい値で終わるLISの中で最長のもの

具体的な解法が思いつかなかったのでAIに聞いてみると以下のよう

自分(`nums[i]`)より小さい値で終わるLISの中で最長のものをO(n)で探している => ボトルネック
事前に整理された情報があればO(log(n))で引ける
- k番目まで見た時点で管理しておくもの
    - 長さ1のLIS: 末尾の最小値
    - 長さ2のLIS: 末尾の最小値
    ....
そして、nums[i+1]がきたときの更新は、二分探索でnums[i+1]以上が初めて出る位置(jとする)をnums[i+1]で置き換える(長さj+1のLISの末尾をより小さく更新)

上記の配列は、単調増加（LISの長さが増えるほど、末尾の最小値ももちろん大きくなる）

```py
class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:
        min_tails_at_length = []
        for num in nums:
            index = bisect_left(min_tails_at_length, num)
            if index == len(min_tails_at_length):
                min_tails_at_length.append(num)
                continue

            min_tails_at_length[index] = num

        return len(min_tails_at_length)
```

## Step2

### 🔴 コードレビュー観点

**変数名のパズル問題（命名）**
> うーん、読みにくいと思ったんですが、理由が `lengths` の意味がパズルになっているからだと思いました。内側のループは、関数にすることができるはずで、「i よりも左で、nums[i] 未満で終わる最大のシーケンスの長さ」を返させればいいですね。

— [hayashi-ay/leetcode#27](https://github.com/hayashi-ay/leetcode/pull/27) (oda)

変数名の候補まとめ（各PRでの議論より）:
- `lengths` → パズルになる（NG）
- `lis_lengths`, `max_subsequence_lengths` → やや良い
- `lis_lengths_ending_with_itself`, `max_lis_length_ending_at_i` → 意図が伝わる
- `min_tails` / `minimum_tail_value_of_lis_of_length` → O(nlogn)解法での推奨名
- `length_to_min_last_values`（1-based化したうえで）→ nodchipさん推奨

**関数への切り出しで意図を明示する**

[haniwachann/leetcode#5](https://github.com/haniwachann/leetcode/pull/5) での実践例：

```cpp
// rightより前の部分配列で、nums[right]よりも小さい値で終わるシーケンスの個数を返す。
int get_maxlength_ended_at_index(int right, const vector<int>& nums, const vector<int>& maxlengths)
```

内側ループを関数化することで「何を求めているか」がコードから読める。

```py
class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:
        def get_maxlength_ended_at_index(right):
            max_length = 0
            for i in range(right):
                if nums[right] <= nums[i]:
                    continue
                
                max_length = max(lis_length_ending_at[i], max_length)
            return max_length


        n = len(nums)
        lis_length_ending_at = [1] * n
        for i in range(n):
            max_length = get_maxlength_ended_at_index(i)
            lis_length_ending_at[i] = max(max_length + 1, lis_length_ending_at[i])
                
        return max(lis_length_ending_at)
```
**MAX_INTの使い方への注意（production観点）**

> MAX_INT は、普通は int の最大値、Python2 では sys.maxint 3 では sys.maxsize C では INT_MAX のことだと考えるでしょう。違うものが入っているのは好ましくないです。
> 数字の場合は、だんだんいろいろな事情で大きな数字が入るようになってきて、気がついたら、ここにその数が流れてきて、10001 を超えていたという事が起きるでしょう。

— [Mike0121/LeetCode#50](https://github.com/Mike0121/LeetCode/pull/50) (oda)

`10**4 + 1` のような制約依存のMAX_INTは脆弱。64ビット符号付き整数の最大値にしておく方が安全（他が壊れてもテストに引っかかりやすい）。

**1-indexedと0-indexedの混在**

> `length` は1-indexedな概念で、bisectの結果やmin_tailsのアクセスは `length - 1` の0-indexedだからです。変数も0-indexedで扱い "index" などの変数名にするか、min_tailsなどの配列側を1-indexedで扱えるように、0番目に番兵を仕込んでおくのも手かなと思います。

— [naoto-iwase/leetcode#36](https://github.com/naoto-iwase/leetcode/pull/36) (naoto-iwase)

indexingのズレを明示的に +1/-1 で表現するか、設計段階で統一するかは意識的に選ぶこと。

---

### 🟡 他の解法

**ループ方向の可読性**

> 「数直線で考えたとき、右側が大きくなるよう、`nums[left] < nums[right]` としたい」

— [Mike0121/LeetCode#50](https://github.com/Mike0121/LeetCode/pull/50) (nodchip)

```python
# こちらの方が直感的
for right in range(1, len(nums)):
    for left in range(right):
        if nums[left] < nums[right]:
```

**tailsが実際のLISの列でない点への注意（follow-up）**

[naoto-iwase/leetcode#36](https://github.com/naoto-iwase/leetcode/pull/36) より：
> LISそのものを返したい場合、tailsがそのままになるかと思ったが、誤り。tailsはvalueの狭義単調増加列にはなるが、インデックスはそうとは限らない。追加の情報を記録する必要がありそう。

例: [2,3,1,4]
tailsは, [2] => [2,3] => [1,3] => [1,3,4] 長さ3は正しいが[1,3,4]は部分列の中に存在しない

LIS自体を復元するには `previous_index` 配列で各要素の前の要素のインデックスを記録し、末尾から逆に辿る実装が必要。
`previous_index[i]`はnums[i]を`tails`の中で探し、そのインデックス-1を記録する
上記の例だと, `previous_index`は[None,None,None,None] => [-1,None,None,None] => [-1,0,None,None] => [-1,0,-1,None] => [-1,0,-1,1]


**セグメント木の位置づけ**

> セグメントツリーは、50行以内で書け、いろいろな複雑なデータ構造の代用品として使えるので重宝されます。ソフトウェアエンジニアの常識には含まれていないと思います。

— [naoto-iwase/leetcode#36](https://github.com/naoto-iwase/leetcode/pull/36) (oda / nodchip)


**bisectを自前実装して理解を深める**

[Mike0121/LeetCode#50](https://github.com/Mike0121/LeetCode/pull/50) のstep2でbisect_leftを自前実装している。標準ライブラリに頼るだけでなく、内部動作を実装できる状態にしておくとよい：

```py
def my_bisect_left(array, num):
    """
        単調増加列arrayの中でnum以上になる最小のインデックスを返す
    """
    left = 0
    right = len(array)
    while left < right: # 半開区間が存在する限り
        mid = (left + right) // 2
        if array[mid] < num:
            left = mid + 1
            continue

        right = mid
    return left
```
`bisect_right`は `array[mid] <= num`になる

二分探索の実装について、挿入位置を求めるには半開区間`[left,right)`, 値の存在確認には閉区間`[left,right]`
閉区間の場合
```py
left, right = 0, len(array) - 1
while left <= right:
    mid = (left + right) // 2
    if array[mid] == num:
        return mid  # 見つかった
    elif array[mid] < num:
        left = mid + 1
    else:
        right = mid - 1
return -1
```

---

### 🟢 その他

**セグメント木の実装議論**

[TORUS0818/leetcode#33](https://github.com/TORUS0818/leetcode/pull/33) でセグ木の query 実装に関する詳細な議論。左の子・右の子の判定ロジック（奇数/偶数判定）についてfhiyoさんが図を使って検証。セグ木の実装バグは具体例（配列長7のケース）で追わないと気づきにくい。

**計算量の見積もり（C++の場合）**

> C++の1秒間の実行ステップ数を 1.0×10^8 とすると、2500^2 / 10^8 ≈ 0.0625秒

— [haniwachann/leetcode#5](https://github.com/haniwachann/leetcode/pull/5)

この数字は公式ではなくコミュニティ知識。実際はCPUのマイクロコード・パイプライン並列化などで桁が合う程度の精度しかない（odaさんより）。

---

### 🔵 フォローアップ

**類題**
- [1235. Maximum Profit in Job Scheduling](https://leetcode.com/problems/maximum-profit-in-job-scheduling/description/) — 二分探索+DPの組み合わせ
- [962. Maximum Width Ramp](https://leetcode.com/problems/maximum-width-ramp/description/) — 単調スタックの応用


## Step3
自作bisect版
```py
class Solution:
    def lengthOfLIS(self, nums: List[int]) -> int:
        def my_bisect_left(array, num):
            """
                単調増加列arrayの中でnum以上になる最小のインデックスを返す
            """
            left = 0
            right = len(array)
            while left < right:
                mid = (left + right) // 2
                if array[mid] < num:
                    left = mid + 1
                    continue

                right = mid
            return left

        min_tails_at_length = []
        previous_index = []
        for num in nums:
            index = my_bisect_left(min_tails_at_length, num)
            if index == len(min_tails_at_length):
                min_tails_at_length.append(num)
                continue

            min_tails_at_length[index] = num

        return len(min_tails_at_length)
```