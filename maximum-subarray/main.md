## Step1
Given an integer array nums, find the subarray with the largest sum, and return its sum.
> Subarray: A subarray is a contiguous non-empty sequence of elements within an array.

Example 1:
Input: nums = [-2,1,-3,4,-1,2,1,-5,4]
Output: 6
Explanation: The subarray [4,-1,2,1] has the largest sum 6.

Example 2:
Input: nums = [1]
Output: 1
Explanation: The subarray [1] has the largest sum 1.

Example 3:
Input: nums = [5,4,-1,7,8]
Output: 23
Explanation: The subarray [5,4,-1,7,8] has the largest sum 23.

Constraints:
- 1 <= nums.length <= 10^5
- -10^4 <= nums[i] <= 10^4

Follow up: If you have figured out the O(n) solution, try coding another solution using the divide and conquer approach, which is more subtle.

Approach
- maxは配列を最後まで見ないとわからないので、配列を順に舐める想定をする
- どんな情報を残すと探索が楽になるか
- subarrayは連続しているのでsubarrayの終わりの位置だけ記録しておけば良さそう
- nums[i]に対して, nums[i]で終わるsubarrayのうち和が最大のものを記録.
- nums[i+1]に対して、dp[i] + nums[i+1]とnums[i+1]の大きさを比べて大きい方を保存する
    - 局所最適だがいけそう

時間計算量: O(N)
空間計算量: O(N)
```py
class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        # 0-indexed
        max_subarray_sum_ending_at = [0] * len(sums)
        max_subarray_sum_ending_at[0] = nums[0]
        for i in range(1, len(nums)):
            max_subarray_sum_ending_at[i] = max(max_subarray_sum_ending_at[i - 1] + nums[i], nums[i])
        
        return max(max_subarray_sum_ending_at)
```

- dpテーブルのi番目はi-1番目にしか依存していないのでprevを変数に格納するだけで良さそう
```py
class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        # 0-indexed
        max_subarray_sum_ending_at = nums[0]
        max_subarray_sum = nums[0]
        for i in range(1, len(nums)):
            max_subarray_sum_ending_at = max(max_subarray_sum_ending_at + nums[i], nums[i])
            max_subarray_sum = max(max_subarray_sum_ending_at, max_subarray_sum)
            
        return max_subarray_sum
```
Kadane'sのアルゴリズムと言うらしい
🤖レビュー
> max_subarray_sum_ending_at は意図が明確で良いです。ただし実態は「現在位置で終わる最大和」なので、末尾に _i や _here をつけると「iで終わる」感が出てより明確かもしれません。

self folowup
Q. 最大和のsubarrayのインデックス範囲を返すようにする
A.
- max_subarray_sumが更新 => (start, end)を更新
- max_subarray_sum_ending_atのほうが大きい => スタートはそのまま、nums[i]のほうが大きい => スタートを更新
- エンドは常に更新

```py
class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        # 0-indexed
        max_subarray_sum_ending_at_i = nums[0]
        max_subarray_sum = nums[0]
        start_of_max_sum_subarray = 0
        end_of_max_sum_subarray = 0
        current_start = 0
        for i in range(1, len(nums)):
            new_subarray_sum_ending_at_i = max_subarray_sum_ending_at_i + nums[i]
            if new_subarray_sum_ending_at_i < nums[i]:
                current_start = i
                max_subarray_sum_ending_at_i = nums[i]
            
            else:
                max_subarray_sum_ending_at_i = new_subarray_sum_ending_at_i

            if max_subarray_sum_ending_at_i > max_subarray_sum:
                start_of_max_sum_subarray = current_start
                end_of_max_sum_subarray = i
                max_subarray_sum = max_subarray_sum_ending_at_i
            
        return max_subarray_sum
```
### 他の解法
- follow upの分割統治法
以下のように考える
- 左半分と右半分にわけ以下の3つのパターンで最大subarrayを計算し、maxをとる
1. subarrayが左半分に完全におさまる場合の最大値
2. subarrayが右半分に完全におさまる場合の最大値
3. 中央をまたぐ（左半分の末尾 + 右半分の先頭）場合の最大値

時間計算量: O(nlog(n))
Master theoremを用いるらしい. いくつかのケースがある
`T(n) = 2T(n/2) + O(n)`(`T(n) = aT(n/b) + f(n)`でa,b = 2,2 f(n) = O(n))

pros: 問題の構造がわかりやすい
cons: スタックオーバーフロー、計算量が大きくなる

直感的には、深さがlog(n)でそれぞれの層の計算にO(n)(max_suffix, max_prefixの計算がO(n), whileで考えるとラク)
空間計算量: O(nlog(n))
```py
class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        # 0-indexed
        def max_suffix(left, mid):
            # nums[mid]で必ず終わるsubarrayの中で和が最大
            if left == mid:
                return nums[mid]

            return max(max_suffix(left, mid - 1) + nums[mid], nums[mid])

        def max_prefix(mid, right):
            # nums[mid]で必ず終わるsubarrayの中で和が最大
            if right == mid:
                return nums[mid]

            return max(nums[mid] + max_prefix(mid + 1, right), nums[mid])
        
        def max_sub_array_helper(left: int, right: int):
            if left == right:
                return nums[left]

            mid = (left + right) // 2
            left_max = max_sub_array_helper(left, mid)
            # !無限再帰に注意
            right_max = max_sub_array_helper(mid + 1, right)
            max_mid_cross_case = max_suffix(left, mid) + max_prefix(mid + 1, right)

            return max(left_max, right_max, max_mid_cross_case)
        
        return max_sub_array_helper(0, len(nums) - 1)
```

## Step2
- https://discord.com/channels/1084280443945353267/1206101582861697046/1207518775851876362
> 累積和とそこまでの累積和の最小値の差」全体の最大値だなと思って、
> scanl (+) 0
> scanl min 0
> max
> となる感覚なんですが、これは書けますでしょうか。それが書けたら scanl foldl は合体してワンパスにできるのでして、少し整理すると上のコードが出てくると思います。

Kadane'sアルゴリズムに至るまでの考え方.
- https://github.com/sakupan102/arai60-practice/pull/33#discussion_r1611415355 参考

- 0 ~ kまでの累積和をすべてのkについて計算したものがあって、それの差の最大値がsubarrayの和の最大値
累積和の計算と差の最大値の計算を合体して1passにする
`max_sum = max(max_sum, current_prefix - min_prefix)`


### コードレビュー観点

#### 変数名: `_so_far` サフィックスの活用
- リンク: https://github.com/Fuminiton/LeetCode/pull/32#discussion_r（nodchipコメント）
> `_so_far` と最後につけて、「ここまでの」を意味する変数名にする方もいらっしゃるようです。

`max_sum_so_far` のように `_so_far` を使うと「現在地点までの最大値」という意図が自然に伝わる。`current_` や `_ending_at_i` と並んで使える表現として覚えておくと良い。

#### 変数名: 変数が表すものとの対応
- リンク: https://github.com/sakupan102/arai60-practice/pull/33#discussion_r（nodchipコメント）
> `max_subarray` は部分列自体を表しているような印象を受けます。`max_sum_subarray` あたりがよいと思います。

#### 1回しか呼ばれない小関数は切り出し不要
- リンク: https://github.com/sakupan102/arai60-practice/pull/33#discussion_r（nodchipコメント）
> `make_prefix_sums()` は1回しか呼ばれておらず、長くもないため、関数化する必要はないと思います。

関数化のコストは「コード量の増加」と「読む側の文脈スイッチ」。1回しか呼ばれない短い処理はインラインに置く方が読みやすい。

#### 番兵の意識的な使用
- リンク: https://github.com/Fuminiton/LeetCode/pull/32#discussion_r（odaコメント）
> maximum_subarray に負の小さい値を入れるというのが「番兵」であるという認識はありますか。それで、入力への制約というのはだんだん守られなくなっていくものなので、番兵を使ってうまく書けないならば、使わないことも考えたほうがいいでしょう。

`-math.inf` や `-sys.maxsize` を初期値として使うとき、それが「番兵」であると意識すること。制約が変わると番兵が機能しなくなる可能性があるので、`nums[0]` を初期値にするか、フラグで初回を判別する実装の方が堅牢なことがある。

#### 更新順序と可読性のトレードオフ
- リンク: https://github.com/Mike0121/LeetCode/pull/51#discussion_r（olsen-blueコメント）
> L128〜L130の方は、最新のcumulative_sumをすぐさまmaxで反映！-> 次のステップのためにmin_cumulative_sumを更新しておく...といった感じで、なんか猪突猛進感がありますね。やりたいことまずさっさと済ませる感じが、私は意外と好きです。

累積和の更新を「先に min を更新してから加算」か「加算してから max を取ってから min を更新」かは、どちらも正しく動く。好みと一貫性を大切に。

---

### 他の解法など

#### 分割統治法をO(n)にする「4値返し」のパターン
- リンク: https://github.com/naoto-iwase/leetcode/pull/37
> 各区間 `[L, R]` について、次の4つを返すようにします：
> 1. `total`: 区間全体の和
> 2. `best_prefix`: 区間の先頭から始まる最大部分和
> 3. `best_suffix`: 区間の末尾で終わる最大部分和
> 4. `best_subarray`: 区間内部の最大部分和
> マージ時: `best_subarray = max(A.best_subarray, B.best_subarray, A.best_suffix + B.best_prefix)`

通常の分割統治法はO(n log n)だが、各区間で4値を保持してマージする方式にするとO(n)に改善できる。`T(n) = 2T(n/2) + O(1)` となるため。これは「最大の空の矩形」など他の問題にも応用可能なパターン。
理解に時間がかかった

#### Kadaneの直感的な理解: 複数のアナロジー
- 標高差アナロジー: https://github.com/olsen-blue/Arai60/pull/32#discussion_r
> 「過去最安からの上げ幅」だけ変数にしておくと、マイナスになったときは最安値が更新されたという意味なので、`prefix_sum - min_prefix_sum` の一変数だけで話がつく

- 相続アナロジー（naoto-iwase）: 「nums[i]を第i世代の生涯収支とみなし、負になったら子供に相続させるのを取りやめる」
- 株の損切りアナロジー（olsen-blue）: 「昨日までの投資先に続けてつっこむか、損切りして新たな投資を始めるかの貪欲な2択を毎日やる」
- Geminiによる対比（mamo3gr）: 「Before: 原点から計った高さと過去最低の高さを両方記録して差を見る / After: 最低地点からの高さだけを記録する。マイナスになったらそこを新たな0地点とみなす。」

---

### その他

#### `sys.maxsize` はintの最小値ではない（Python）
- リンク: https://github.com/Fuminiton/LeetCode/pull/32#discussion_r（fuga-98コメント）
> `-sys.maxsize - 1` はintの最小値ではなさそうです。
> `sys.maxsize` の説明: "The largest positive integer supported by the platform's Py_ssize_t type, and thus the maximum size lists, strings, dicts, and many other containers can have."

Pythonの `sys.maxsize` はコンテナのサイズ上限（`Py_ssize_t`の最大値）であり、整数の最大値ではない。Pythonの `int` は任意精度なので理論上の最大値は存在しない。番兵として使いたい場合は `-math.inf` や `float('-inf')` が意図を正確に表す。

#### `float` -> `int` の暗黙型変換（Python）
- リンク: https://github.com/Mike0121/LeetCode/pull/51 diff（Mike0121のコメント）
> `subarray_sum = 0, max_subarray_sum = -float('inf')` で初期化してループを0から始めても良い。その場合、可読性は高いかもしれないがfloat -> intの型変換が起こるため自分はこちらを採用。

`-float('inf')` を初期値にすると `max()` の結果が最終的に `int` に戻るが、Pythonでは `max(int, float)` が `float` を返すため、戻り値の型が `float` になりうる。型アノテーションが `int` の場合は注意が必要。

#### ネストした関数からの状態管理: `nonlocal` vs クラス変数 vs ペアで返す
- リンク: https://github.com/olsen-blue/Arai60/pull/32 会話（oda, olsen-blue）
> max_path は `nonlocal` にしたほうがいいのではないですかね。でなければ、ペアで返すというのも1つです。

再帰関数の中で外側の変数を更新する場合の3つの選択肢:
1. `self.xxx` としてクラス変数に持つ（副作用あり、スコープが広い）
2. `nonlocal` で外側の変数を参照（副作用あり、スコープは狭い）
3. タプルやdataclassでペアを返す（副作用なし、関数型スタイル）

副作用のないペア返しは純粋な関数になるが、コードがやや複雑になる。`namedtuple` や `dataclass` を使うと可読性を保ちながら副作用を排除できる。

---

### フォローアップ質問など

#### 面接での思考プロセス: 素朴な解法を捨てない
- リンク: https://github.com/mamo3gr/arai60/pull/30
> どうせ、1番上は思いついたけれども、価値のないものだと思って捨てたでしょう。そこがいかんのですよ。

brute-force解をまず提示し、その上で改善を議論するのがSWEとして自然な面接対応。最適解の発想をいきなり狙って黙り込むより、確実に解ける方法を示した上でTradeoffsを話す方が評価される。「電車が止まったときにタクシーや徒歩という代替手段を知っているか」という理解の深さを見ている。

この問題の場合、「dp[i][j]がnumsの[i,j]区間の配列の和を表すように設計し、更新則を考える」などがナイーブな方法になる？（いきなりメモ化してしまっているのでもうちょっとシンプルなのが一番最初に思いつくかも）

#### フォローアップ: テストケースを自力で設計する
- リンク: https://github.com/Mike0121/LeetCode/pull/51#discussion_r
> ジャッジシステムというテストケースなどが与えられている状況ではなくて、そういうものがないときに、どうやって自分のコードが問題のないものであるということを提示するか。

テストケースの自己設計能力: 全て正の場合、全て負の場合、0を含む場合、長さ1の場合、大規模入力（スケール確認）、空配列（制約外だが例外系）を一通り考えられるか。
この問題の場合
- [1,2,0,1,3]
A. 7

- [2,1,-5,4,6,-5]
A. 10

- [2,1,-1,4,6,-5]
A. 12

- [-2,-2,-1,-1]
A. -1

- [-1]
A. -1

- []
A. error

#### フォローアップ: 並列処理への応用
- リンク: https://github.com/Fuminiton/LeetCode/pull/32
> 分割統治は、並列処理が適切な場面では選択肢になるのだろうか

分割統治法はサブ問題が独立しているため並列化しやすい。MapReduceの文脈でも同様のパターンが使われる（各ノードで区間の4値を計算してマージする）。

## Step
```py
class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        max_subarray_sum_so_far = nums[0]
        max_subarray_sum = nums[0]
        for i in range(1, len(nums)):
            max_subarray_sum_so_far = max(max_subarray_sum_so_far + nums[i], nums[i])
            max_subarray_sum = max(max_subarray_sum_so_far, max_subarray_sum)
            
        return max_subarray_sum
```