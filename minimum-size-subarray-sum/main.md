Given an array of positive integers nums and a positive integer target, return the minimal length of a subarray whose sum is greater than or equal to target. If there is no such subarray, return 0 instead.

Example 1:
Input: target = 7, nums = [2,3,1,2,4,3]
Output: 2
Explanation: The subarray [4,3] has the minimal length under the problem constraint.

Example 2:
Input: target = 4, nums = [1,4,4]
Output: 1

Example 3:
Input: target = 11, nums = [1,1,1,1,1,1,1,1]
Output: 0

Constraints:
- 1 <= target <= 10^9
- 1 <= nums.length <= 10^5
- 1 <= nums[i] <= 10^4

Follow up: If you have figured out the O(n) solution, try coding another solution of which the time complexity is O(n log(n)).

Approach
- 2重ループでナイーブに実装してみる。nums[j: i]という部分列に対して和を計算し、targetと比較、最小の長さを更新する。これは簡単に実装できるが、計算量がO(N^3)なので確実にTLE

- 主な問題は毎回和をゼロから計算していることと内側のループが多分無駄っぽい
- 部分列の和は、前やった問題の記憶から累積和を使うと効率的に計算できる。
- また、内側のループで探しているのは、「位置iで終わる部分列の和がtarget以上となる最大のj(<= i)」であり、累積和は単調増加なので二分探索を使えばうまく探せそう。計算量はO (nlogn)に抑えられそうだと気づく。

つまったところ
- `prefix_sums[i] - target`と等しい、`prefix_sums[j]`であるjがちょうど見つかった時と一致するものがない時で長さの計算が違うので場合分けしないといけなかった。

ACしたが処理時間を見ると、最頻値の5 ~ 6倍ほど平均的に遅い。O(n)の回答が多分ありそう
- 時間：O (nlogn)
- 空間: O(n)
```py
class Solution:
    # 36分くらいかかった
    def minSubArrayLen(self, target: int, nums: List[int]) -> int:
        n = len(nums)
        min_subarray_len = float('inf')
        # subarrayということは累積和が使えそう
        # 累積和は単調増加なので、二分探索で効率的に探索できる
        prefix_sum = 0
        prefix_sums = []
        sum_to_index = {}
        for i, num in enumerate(nums):
            prefix_sum += num
            prefix_sums.append(prefix_sum)
            sum_to_index[prefix_sum] = i
        for i in range(n):
            # ここのループをlognにする
            # sum of nums[j] ~ nums[i] = prefix[i] - prefix[j - 1]>= target prefix[j - 1] <= prefix[i] - targetとなる最大のjを見つける
            if prefix_sums[i] < target:
                continue
            
            complement = prefix_sums[i] - target
            if complement in sum_to_index:
                # ちょうどあった場合はそれを使う
                min_subarray_len = min(min_subarray_len, i - sum_to_index[complement])
            else:
                idx = bisect.bisect_left(prefix_sums, complement)
                min_subarray_len = min(min_subarray_len, i - idx + 1)
        
        if min_subarray_len == float('inf'):
            return 0
        
        return min_subarray_len
```

🤖レビュー
> sum_to_index の使い方が誤っています。                                     complement in sum_to_indexで「ちょうど一致」を優先していますが、求めたいのは「prefix[j-1] <= complementを満たす最大の j-1」です。complement にちょうど一致する prefix が複数あった場合は最後のを取りたいわけですが、それより手前で prefix > complement の値があっても辞書には別キーとして残るので、そもそもこの分岐は二分探索より良い情報を与えません。この分岐は不要で、二分探索一本に統一すべきです。

-> nums[i]は0を含まないので累積和は狭義単調増加で、上記の指摘は当たらないが0も含む時に拡張ができないので二分探索に統一した方が良い

> 加えて bisect 側にもバグ。                                                   idx = bisect.bisect_left(prefix_sums, complement)                             
min_subarray_len = min(min_subarray_len, i - idx + 1)                       

bisect_left は complement が入る最左位置(またはcomplement以上の中で一番左のインデックス) = prefix_sums[idx] >= complementとなる最小 idx。欲しいのは prefix[j-1] <= complement の最大 j-1なので、bisect_right(prefix_sums, complement) - 1 が正解。長さは i - (j-1) = i - (bisect_right(...) - 1)。                                                

例: target=7, nums=[2,3,1,2,4,3], prefix=[2,5,6,8,12,15]。i=4 (prefix=12)のとき complement=5。期待は j-1=1 (prefix=5) → 長さ 3。
- bisect_right([2,5,6,8,12,15], 5) - 1 = 2 - 1 = 1 ✓                          
- 現コード: 5 in sum_to_index → True → 4 - 1 = 3 …たまたま合うが、bisect_left
分岐に落ちると bisect_left=1, i - 1 + 1 = 4 と間違える。

書き直し
```py
class Solution:
    def minSubArrayLen(self, target: int, nums: List[int]) -> int:
        n = len(nums)
        min_subarray_len = float('inf')
        prefix_sum = 0
        prefix_sums = []
        for i, num in enumerate(nums):
            prefix_sum += num
            prefix_sums.append(prefix_sum)
        for i in range(n):
            if prefix_sums[i] < target:
                continue
            
            complement = prefix_sums[i] - target
            idx = bisect.bisect_right(prefix_sums, complement)
            min_subarray_len = min(min_subarray_len, i - idx + 1)
        
        if min_subarray_len == float('inf'):
            return 0
        
        return min_subarray_len
```

🤖 review
- `prefix_sum` と `prefix_sums` は単複1文字違いで紛らわしい。役割で `running_total` などに分ける
- `idx` は何のインデックスか不明 → 部分配列の左端を指すなら `left`、右端は `right` と意味づけ
- `prefix_sums` に番兵 `0` を入れると、長さ計算の `+1`/`-1` が消えて意図が直接コードに出る

番兵なしのとき、`prefix_sums[i]` は「`nums[0..i]` の和」で、累積和のインデックスと nums のインデックスが**一致**している。
部分配列 `nums[j..i]` の長さは `i - j + 1`、二分探索で得るのは `j-1` なので `i - (j-1) = i - idx + 1` と `+1` が出る。
番兵 `0` を先頭に入れると、`prefix_sums[i]` は「左から i 個の和」となり、インデックスは nums の**境界**を指すように変わる。
```
nums:        [2, 3, 1, 2, 4, 3]
prefix_sums: [0, 2, 5, 6, 8,12,15]
              ↑           ↑
            left=0      right=4
            差 = 4 = nums[0..3] の長さ
```
部分配列 `nums[left..right-1]` の和 = `prefix_sums[right] - prefix_sums[left]`、長さは `right - left` でそのまま引き算になる。「要素を指す」から「境界を指す」への切り替えで `+1` が消える、と理解する。
```py
class Solution:
    def minSubArrayLen(self, target: int, nums: List[int]) -> int:
        prefix_sums = [0]
        running_total = 0
        for num in nums:
            running_total += num
            prefix_sums.append(running_total)

        min_subarray_len = float('inf')
        for right in range(1, len(prefix_sums)):
            if prefix_sums[right] < target:
                continue
                
            complement = prefix_sums[right] - target
            left = bisect.bisect_right(prefix_sums, complement) - 1
            min_subarray_len = min(min_subarray_len, right - left)

        return min_subarray_len if min_subarray_len != float('inf') else 0
```

別解
時間計算量がO(n)の回答としてスライディングウィンドウを用いたものを実装してみる
1. はじめは右端と左端は重なっている。右端を動かして要素を足していく。
2. targetを超えたら左端を縮める。その際ウィンドウから外れた要素は引いていく
3. 右端が末尾を超えたら終了

- 空間計算量：O(1)
```py
class Solution:
    def minSubArrayLen(self, target: int, nums: List[int]) -> int:
        left, right = 0, 0
        total = 0
        min_subarray_len = float('inf')
        while right < len(nums):
            total += nums[right]
            while left <= right and total >= target:
                min_subarray_len = min(min_subarray_len, right - left + 1)
                total -= nums[left]
                left += 1
            
            right += 1

        if min_subarray_len == float('inf'):
            return 0

        return min_subarray_len
```

🤖
- `while left <= right and total >= target:`の前半の条件は不要
    - パッと考えて防御的に入れてしまったがよく考えると到達しない条件なので不要
    - 冗長な条件は読み手に余計なことを考えさせてしまうので良くない
    - 理由: `nums[i] >= 1` かつ `target >= 1` なので、`left == right` の時点で `total -= nums[left]` により `total` は必ず 0 になり、`0 >= target` が偽になって内側ループを抜ける。`left` は `right` を追い越せない
- ただし制約が変わると `left <= right` が必要になる
    - `target = 0` を許すと `total >= 0` がずっと真 → 無限ループ
    - `nums[i] = 0` を許すと、左を進めても `total` が減らず抜けられない
    - これらのケースでは `left <= right`（または `left < n`）の防御が必要

## Step2

### 分割統治法
[naoto-iwase#50](https://github.com/naoto-iwase/leetcode/pull/50#discussion_r2483829525)
> 半分に割って分割統治することを繰り返すという方法があります。中央をまたぐ場合とまたがない場合に分類します。

**分割統治**で時間計算量O (nlogn)で解く。 `T(n) = 2T(n/2) + O(n)` と分解する。配列を中央で分け、(a) 左半分内の最小、(b) 右半分内の最小、(c) 中央をまたぐ最小、の3つの min を取る。マージソートと同じ構造。


(c)はマージソートの要領で最小値を探す処理を書く。結構複雑

[naoto-iwase#50](https://github.com/naoto-iwase/leetcode/pull/50#discussion_r2496849858) 
> `i` を左に延ばしたときに、`j` を右に縮められる余地を検討できていません。例えば `nums = [12,28,83,4,25,26,25,2,25,25,25,12]`, `target = 213` のケースで失敗します。

i を左に伸ばすと total が増える → 既に target を超えていたら **j を左に縮められる**かもしれない、というのを忘れがち。スライディングウィンドウの「縮める」操作と同じ発想を再帰の中でも使う必要がある。

### bisect_left でも nums に 0 を許す場合に対応できるか
[olsen-blue#50](https://github.com/olsen-blue/Arai60/pull/50#discussion_r2003932068)
> 0が入っていたとしても、基本的にこの問題は同様に解けるはずです。この場合は bisect_left を使っていても大丈夫ですね。

この問題で議論したのは「`<= complement` の最大インデックス」を取りに行くために `bisect_right - 1` を使う形だった。一方、forループで、部分列の左側を動かすとして、累積和を「`>= target + prefix[left]` の最小インデックス」を探す形にすると話が変わる：
- 0 を含むと累積和は **広義** 単調増加（フラットな領域ができる）
- 「target以上の最初」を探すなら `bisect_left` で先頭の一致を取りたい → bisect_left が正しい
- 「targetより大きい最初」を探すなら `bisect_right` を使う

つまり「探したい条件（以上 / より大きい）」と bisect の選択が対応していて、**広義単調でも正しい関数を選べば動く**。今回 0 が制約で除外されているからどちらでも動くが、一般化を考えると区別が大事。

### `min_length` の初期値どれを使う？
複数のPRで議論されている：
- `math.inf`: 「明らかに異物」で意図が伝わるが **float になる** のが微妙
- `sys.maxsize`: int で固定、巨大な値であることが意図として伝わる
    - デメリットとしてプラットフォーム依存で値が変わったり、Pythonの整数は任意精度なので厳密な最大サイズではないこと

- `len(nums) + 1`: 答えうる最大値+1。マジックナンバー感は薄いが「なぜ +1？」が唐突

[olsen-blue#50](https://github.com/olsen-blue/Arai60/pull/50)：
> len(nums) + 1 ならいいですが、唐突な感じを受けますね。

`INF = len(nums) + 1` のような命名が良さそう

### bisect の `key` 引数（Python 3.10+）
[mamo3gr#46](https://github.com/mamo3gr/arai60/pull/46) の `step2_prefix_sum_and_binary_search.py`:
```py
last = bisect.bisect_left(
    prefix_sum, complement,
    lo=start,
    key=lambda p: p - prefix_sum[start],
)
```
Python 3.10 から `bisect` に `key` 引数が追加され、リストを変換せずに「変換後の値で二分探索」できるようになった。`lo` で開始位置も指定できるので、累積和の差を直接探索できる。ただし可読性は落ちるので、番兵 0 を入れた `bisect_right(prefix, complement) - 1` の方が素直。

## Step3
スライディングウィンドウを練習する
```py
class Solution:
    def minSubArrayLen(self, target: int, nums: List[int]) -> int:
        left = 0
        INF = float('inf')
        window_sum = 0
        min_subarray_len = INF 
        for right in range(len(nums)):
            window_sum += nums[right]
            while window_sum >= target:
                min_subarray_len = min(min_subarray_len, right - left + 1)
                window_sum -= nums[left]
                left += 1
        
        if min_subarray_len == INF:
            return 0

        return min_subarray_len
```

## 類題
- [862. Shortest Subarray with Sum at Least K](https://leetcode.com/problems/shortest-subarray-with-sum-at-least-k/)
- [713. Subarray Product Less Than K](https://leetcode.com/problems/subarray-product-less-than-k/) 
- [3. Longest Substring Without Repeating Characters](https://leetcode.com/problems/longest-substring-without-repeating-characters/)
- [76. Minimum Window Substring](https://leetcode.com/problems/minimum-window-substring/)
- [560. Subarray Sum Equals K](https://leetcode.com/problems/subarray-sum-equals-k/)
