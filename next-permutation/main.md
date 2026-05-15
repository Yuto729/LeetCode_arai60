31. Next Permutation

A permutation of an array of integers is an arrangement of its members into a sequence or linear order.

For example, for arr = [1,2,3], the following are all the permutations of arr: [1,2,3], [1,3,2], [2, 1, 3], [2, 3, 1], [3,1,2], [3,2,1].
The next permutation of an array of integers is the next lexicographically greater permutation of its integer. More formally, if all the permutations of the array are sorted in one container according to their lexicographical order, then the next permutation of that array is the permutation that follows it in the sorted container. If such arrangement is not possible, the array must be rearranged as the lowest possible order (i.e., sorted in ascending order).

For example, the next permutation of arr = [1,2,3] is [1,3,2].
Similarly, the next permutation of arr = [2,3,1] is [3,1,2].
While the next permutation of arr = [3,2,1] is [1,2,3] because [3,2,1] does not have a lexicographical larger rearrangement.
Given an array of integers nums, find the next permutation of nums.

The replacement must be in place and use only constant extra memory.

 
Example 1:
Input: nums = [1,2,3]
Output: [1,3,2]

Example 2:
Input: nums = [3,2,1]
Output: [1,2,3]

Example 3:
Input: nums = [1,1,5]
Output: [1,5,1]

Constraints:
- 1 <= nums.length <= 100
- 0 <= nums[i] <= 100

## Step1
色々考えてわかりそうだったが、答えには至らず

以下ヒントなどをみながらの考察
ex. [1,2,3] -> [1,3,2]
[1,2,3]の次は[1,3,2]となるが、なぜそうなるのかを考えてみる。
先頭はそのままで、後ろの[2,3]が昇順なのでまだ大きくする余地がある。[2,3] -> [3,2]に入れ替える。
配列を後ろから見ていき、昇順か降順かをチェックすると良さそう

ex. [1,3,2] -> [2,1,3]
後ろ2桁が降順なのでこれ以上大きくできない。1桁も含めるようにする。先頭の1を末尾の2と入れ替える。-> [2,3,1] さらに, [3,1]を昇順に直すと答えになる

上記の作業をまとめると、右端から走査して最初に下がる(nums[i] < nums[i+1]ということ)位置を見つける。その位置をiとする。iより右側で、nums[i]より大きい最小の数の位置jを探すし、iとjの位置を入れ替える。
最後に、iより右側を反転して終了。もしiが見つからない場合は、配列全体を反転する。

Time: O(N) 内側のループは条件文を満たした場合のみに入るが、条件を満たせば必ずreturnするので最悪計算量はO(N)

Space: O(N) スライス反転分
```py
class Solution:
    def nextPermutation(self, nums: List[int]) -> None:
        """
        Do not return anything, modify nums in-place instead.
        """
        for i in range(len(nums) - 2, -1, -1):
            if nums[i] < nums[i + 1]:
                # iより右側でnums[i]より大きい最小の数の位置jを探す
                for j in range(len(nums) - 1, i, -1):
                    if nums[j] > nums[i]:
                        break

                nums[i], nums[j] = nums[j], nums[i]
                # iより右側を反転する
                nums[i + 1:] = reversed(nums[i + 1:])
                return
        
        # iが見つからない場合
        nums.reverse()
```
- `reversed`関数と`nums[i+1:]`のスライス生成で2回コピーが発生すると思ったが、`reversed`はイテレーターを作るだけなのでO(1)らしい。
    - https://docs.python.org/3/library/functions.html#reversed
    - 最初は, `nums[i + 1:][::-1]`で反転を記述していたが、こちらはスライスを2回作っているので`reversed`よりメモリを消費する

- そもそも`reverse`関数で、新たな配列が生成されるので、"The replacement must be in place and use only constant extra memory."に違反している。
以下のように書き換えた

Space: O(1)
```py
class Solution:
    def nextPermutation(self, nums: List[int]) -> None:
        """
        Do not return anything, modify nums in-place instead.
        """
        def reverse_suffix(arr, start):
            left, right = start, len(arr) - 1
            while left < right:
                arr[left], arr[right] = arr[right], arr[left]
                left += 1
                right -= 1

        for i in range(len(nums) - 2, -1, -1):
            if nums[i] < nums[i + 1]:
                # iより右側でnums[i]より大きい最小の数の位置jを探す
                for j in range(len(nums) - 1, i, -1):
                    if nums[j] > nums[i]:
                        break

                nums[i], nums[j] = nums[j], nums[i]
                # iより右側を反転する
                reverse_suffix(nums, i + 1)

                return

        # iが見つからない場合
        nums.reverse()
```

- Previous Permutationはどう解ける?
    - nums[i] < nums[i + 1]を逆にする
    - iより右側でnums[i]より大きい最小の数の位置j -> **nums[i]より小さい**. 反転は同じ。

## Step2

### 償却計算量の観点
[olsen-blue#59](https://github.com/olsen-blue/Arai60/pull/59#discussion_r2030531369)
> ひっくり返すポイントを見つけるのに、自乗のオーダーがかかっているので、これの最悪計算量は O(n^2) ですね。しかし、償却計算量を考えると、そうではなさそうです。長さ k がひっくり返る確率は、k/(k+1) * 1/k! ... これに k^2 をかけて期待値を計算すると、∑ k^2 / k! で上から抑えられるのですが、これは発散しないので定数時間ですね。

`nextPermutation` を全順列に対して順に呼び出した場合、長さ `k` の suffix が反転される確率は `k/(k+1) * 1/k!` で、`k!` の急減衰により期待値 `∑ k²/k!` が収束 → **償却計算量は O(1)**。最悪は O(n) だが、平均的には非常に軽い処理になる、という観点。償却計算量と平均計算量の違い（前者：ある最悪入力列に対する平均、後者：全入力に対する平均）

### デッドコード（到達不能コード）を書くべきか
[olsen-blue#59](https://github.com/olsen-blue/Arai60/pull/59#discussion_r2030531369)
> 原理的に、コンピュータがコードが到達可能か不可能かを判定することは不可能です。これはチューリングマシンの停止性問題は判定できないことからいえます。... 例外を書くのはいいですが、そうでなければ、私はデッドコードは基本的に書かないほうがよいと思っています。

「絶対に来ないはず」の `assert` や例外を書くか問題。停止性問題に絡めて、コンパイラの到達性判定が原理的に不完全であることを踏まえた議論。型システムで意図を表現できるならそちら、そうでないならコメントで十分というスタンス。

### 変数を初期化のためにループで上書きすると意図が読み取れない
[Ryotaro25#63](https://github.com/Ryotaro25/leetcode_first60/pull/63#discussion_r2011056670)
> これを見て、first_increasing_order_index の初期化がここで終了したという理解は構造からは得られないと思うんですよね。... 初期化するために繰り返し変更すると意図が追いにくくなるでしょう。

`for` の中で代入し続けて最終値を「結果」として使うパターンの可読性問題。改善案は (1) ループ前にデフォルト値を入れて見つけたら `break`、(2) 関数に切り出して `const` で受け取る、の2つ。今回の自分の実装で `for j in range(...): if ... break` の後に `j` を使っている部分も同根の指摘で、関数化したほうが意図が読み取りやすい。
`const int first_increasing_order_index = get_first_increasing_order(nums);`

### `next_permutation` は C++ 標準ライブラリにある／参考実装
[usatie#2](https://github.com/usatie/leetcode/pull/2#discussion_r1937025415)
> https://en.cppreference.com/w/cpp/algorithm/next_permutation 一応こちらに参考実装がございます。

内部実装
- reverse iterator を使って「右から走査」を「順方向の `is_sorted_until`」に書き換えている。走査方向の概念が iterator のラッパーに吸収され、アルゴリズムが標準部品の組み合わせで書ける。
- pivot 探索 = is_sorted_until、swap 相手探索 = upper_bound（reverse iterator 上では昇順なのでそのまま二分探索が効く）、交換 = iter_swap、suffix 反転 = reverse、と4ステップが全部標準ライブラリで表現される。
- 最後の std::reverse(left.base(), last) を if の外に出していて、pivot が見つからなかった場合は left.base() == first になり配列全体反転 = 最小の順列に戻す処理が同じ1行で吸収される。特殊ケースで分岐しない

### `<=` と `<` の使い分けで suffix が常に降順になることを保証
[shining-ai#58](https://github.com/shining-ai/leetcode/pull/58)
> L17のmin_numとの比較を `<=` に変えてあげれば、leftの右側は降順になるので単純にreverseするだけでよくなります。

重複要素があるときに「`nums[i]` より大きい最小」を探す比較を `<=` にすることで、swap 後も右側が降順を保つ（→ reverse だけでソート完了）。今回の自分の実装は `>` で右から線形に探しているので同じ性質を満たしているが、なぜ単純な reverse で済むのかの不変条件をきちんと意識する観点。
なぜreverseでok?
-> reverseする前提は、「i + 1以降が降順であること」。

### 降順領域の二分探索：負号トリックか専用関数化か
[naoto-iwase#59](https://github.com/naoto-iwase/leetcode/pull/59)
> ```python3
> bisect.bisect_left(nums, -nums[pivot], lo=pivot + 1, key=lambda x: -x)
> ```
> ただこれは可読性が低く、ここは計算量的にボトルネックにならないので線形探索とし、... が良い気がしました。

降順領域で二分探索したい時は、`key=lambda x: -x` で値を反転して `bisect` に食わせるトリックがある。ただし可読性が落ちるので、suffix のサイズが効いてくる場面でなければ線形探索が良い、という判断。自分の実装で「`bisect_right` を昇順前提のまま使ってバグる」と話した点とつながる。

### 関数の引数設計：ハードコード vs 引数で渡す
[naoto-iwase#59](https://github.com/naoto-iwase/leetcode/pull/59)
> 個人的には反対で、もしstep=-1を関数内にハードコードする場合関数名にstep=-1分の情報を追加する必要があると思います。それよりは、引数でfirst, last, stepを渡す方が可読性が高いと感じます。組み込み関数range()などで比較的馴染みのある引数セットであることが根拠の1つです。

「逆順専用関数」にして `step` を埋め込むか、`range(start, stop, step)` 風に引数で渡すか。馴染みあるシグネチャ（`range`、`slice`）を踏襲することで読み手の認知負荷を下げる、という観点。

---

## Step3
- `pivot`がない場合の特殊ケースの分岐を無くす -> C++のnextPermutation実装を参考に
- nums[pivot]より大きい要素の中で最小の要素の特定を関数に切り出す -> 前のコードだと初期化したように読めない

```py
class Solution:
    def nextPermutation(self, nums: List[int]) -> None:
        """
        Do not return anything, modify nums in-place instead.
        """
        n = len(nums)
        def reverse_suffix(start):
            left = start
            right = n - 1
            while left < right:
                nums[left], nums[right] = nums[right], nums[left]
                left += 1
                right -= 1

        def find_swap_target(pivot):
            # pivotより右は降順。右から見て最初に nums[pivot]より大きい要素 = nums[pivot]より大きい要素の中で最小の要素
            for j in range(n - 1, pivot, -1):
                if nums[j] > nums[pivot]:
                    return j
            
            return -1

        pivot = -1
        #　右から見て初めて昇順となる位置を探す
        for i in range(n - 2, -1, -1):
            if nums[i] < nums[i + 1]:
                pivot = i
                break
        
        if pivot != -1:
            target_index = find_swap_target(pivot)
            nums[pivot], nums[target_index] = nums[target_index], nums[pivot]
        
        reverse_suffix(pivot + 1)
```

## 類題
- https://leetcode.com/problems/permutations/
- https://leetcode.com/problems/permutations-ii/
- https://leetcode.com/problems/permutation-sequence/
- https://leetcode.com/problems/next-greater-element-iii/