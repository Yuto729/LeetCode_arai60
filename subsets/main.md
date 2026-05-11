Given an integer array nums of unique elements, return all possible subsets (the power set).
The solution set must not contain duplicate subsets. Return the solution in any order.
> A subset of an array is a selection of elements (possibly none) of the array

Example 1:
Input: nums = [1,2,3]
Output: [[],[1],[2],[1,2],[3],[1,3],[2,3],[1,2,3]]

Example 2:
Input: nums = [0]
Output: [[],[0]]

Constraints:
- 1 <= nums.length <= 10
- -10 <= nums[i] <= 10
- All the numbers of nums are unique.


## Step1
Approach
- 最大の長さで2^10 = 1024通り
- 上記を踏まえるとそれぞれについて含むか含まないかの二通りの選択をしていけば良さそう
- 先頭から樹形図を書いてみる

15分ほど
時間計算量: O(n * 2^n)
空間計算量: O(n + n * 2^n)
```py
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        if not nums:
            return [[]]
        
        n = len(nums)
        def backtrack(index, subset):
            if index == n:
                result.append(subset[:])
                return
            
            backtrack(index + 1, subset)
            subset.append(nums[index])
            backtrack(index + 1, subset)
            subset.pop()

        result = []
        subset = []
        backtrack(0, subset)

        return result
```

上記の再帰を素直にiterativeで書き直す

時間計算量: O(n * 2^n)
空間計算量: O(n^2 + n * 2^n) -> stackの最大サイズはO(n)で、それぞれのエントリがsubsetのコピーを持っているので、出力を除けばO(n^2)
```py
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        if not nums:
            return []
        
        n = len(nums)
        stack = [(0, [])]
        result = []
        while stack:
            index, subset = stack.pop()
            if index == n:
                result.append(subset[:])
                continue
            
            stack.append((index + 1, subset[:]))
            stack.append((index + 1, subset + [nums[index]]))
        
        return result
```


他のiterativeなやり方
Cascading
- これまでの全部分集合に、新しい要素を足したものを追加する
- 2^nの組みを直接逐次的に生成していく方法。
- 「nums[i]までは処理しておいたから残りを追加するかしないか決めて」という引き継ぎ
    - nums[i]まで処理した結果としてsubsetがあり、それぞれに対してnums[i+1]を追加するかしないかで新しくsubsetを追加する

init: [[]]
num=1: [[], [1]] -> 1を選ばなかった場合と選んだ場合に対応
num=2: [[], [1], [2], [1,2]] -> 上記のそれぞれの場合に対して、「2を選ぶか選ばないかの選択を追加する」
num=3: [[], [1], [2], [1,2], [3], [1,3], [2,3], [1,2,3]]

```py
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        result = [[]]
        for num in nums:
            result += [subset + [num] for subset in result]
        
        return result
```

別の再帰のやり方
- 現在のsubsetは常に有効な部分集合。そこからまだ使っていない要素を１つ選んで伸ばすことを全パターン試す方法
- include/excludeパターンは各要素について２択を順に決めるのに対して、こちらの解法は今ある集合に次に何を追加するかを選ぶという発想
- permutationsなどの「集合を構築していく系」の問題に転用できるテンプレート

```py
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        result = []
        def backtrack(start, subset):
            result.append(subset[:])
            for i in range(start, len(nums)):
                subset.append(nums[i])
                backtrack(i + 1, subset)
                subset.pop()
        
        backtrack(0, [])
        return result
```

その他の解法
- bit mask パターン
    - n個の要素それぞれに「含める（1）/ 含めない（0）」のbitを割り当てる。0から2^n - 1までの整数をbit列として解釈すれば、全2^n通りの組み合わせを列挙できる
```py
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        n = len(nums)
        result = []
        # 0 ~ 2^n - 1
        for mask in range(1 << n):
            subset = []
            for i in range(n):
                # i桁目が1である
                if mask >> i & 1:
                    subset.append(nums[i])
            result.append(subset)

        return result
```

Follow-up                                                   
- nums に重複がある場合（Subsets II, LC 90）はどう拡張しますか？
    - 「追加」か「除外」の選択にて、「除外」を選んだら同じ値の連続を全部スキップする（１個目の再帰の拡張）
    - 上記の「別の再帰」で、numsをソートした上で、同じ再帰階層での２回目以降の同値はスキップする


## Step2

### Backtrackにおける変数名のベストプラクティス

[Ryotaro25#55](https://github.com/Ryotaro25/leetcode_first60/pull/55)
> partial_subsetは、具体的にどういうものか少し名称としてわかりにくく感じます。この場合、numを含むsubsetなので、subset_including_numなどでしょうか？

[mamo3gr#48](https://github.com/mamo3gr/arai60/pull/48)
> fixed と remaining の組み合わせは個人的にわかりやすく感じました。

[fhiyo#51](https://github.com/fhiyo/leetcode/pull/51)
> 個人的にこれがi, jなのはやや読みにくく感じました(変数名)。jはnum_shiftとか？

これらのレビューから抽出できる原則:

1. **「中身/役割」を表す名 前にする**
   - ❌ `partial_subset`, `current`, `path` — 抽象度が高すぎて読み手が中身を想像できない
   - ⭕ `subset_including_num`, `fixed` (確定済み) / `remaining` (未確定) — 何が入っているかが名前で分かる

2. **インデックスは「役割」で命名する**
   - ❌ `i`, `j`, `current` — 添字なのか値なのか不明
   - ⭕ `index`, `start` (探索開始位置), `position` — 添字であること・どんな添字かが伝わる

3. **状態の対(pair)は対称な命名にする**
   - `fixed` / `remaining`、`included` / `excluded` のように対比が見える名前が読みやすい

4. **スコープが狭ければ短くて良い**
   - 数行内で閉じるループ変数は `i` でも可。長く生きる変数ほど説明的に。

#### 今回の自分のコードへの適用

```py
def backtrack(index, subset):     # index = 添字であることを明示
    ...
```

- `index`: 「nums のどこまで処理したか」を表す添字 → そのまま `index` でOK
- `subset`: 構築中の部分集合 → スコープが関数内で完結するので短くて可。より明示的にするなら `subset_so_far` / `current_subset`

start-indexパターンの場合:
```py
def backtrack(start, subset):     # start = 「ここから先の要素を候補にする」
```
`start` は探索範囲の起点、と役割が明確なのでこのままで良い。

#### 関数名にも「役割+目的語+入力の意味」を込める

`backtrack` / `dfs` は **手段** を表すだけで、何を生成しているかが読み取れない。[mamo3gr#48](https://github.com/mamo3gr/arai60/pull/48) の `generate_subsets_from(start)` は「`start` 以降の要素を使って subsets を生成する」と**役割・目的語・入力の意味**が一語で分かる優れた命名。

命名の型:

| 要素 | 役割 | 例 |
|---|---|---|
| 動詞 | 何をするか | `generate` / `build` / `extend` / `decide` |
| 目的語 | 何を作るか | `subsets` |
| 前置詞句 | 入力の意味 | `_from(start)` = 「ここから先を使って」 |

自分の解法に当てはめると:

- **include/exclude版**: `build_subsets_from(index, subset)` — 「`index` 以降について含む/含まないを決めて subsets を作る」
- **start-index loop版**: `extend_subset_from(start, subset)` — 「`subset` を `start` 以降の要素で伸ばしていく」

`backtrack(index, subset)` だと動詞しかなく目的語が消えていて、`index` が何を表すかも自明でない。**動詞+目的語+入力の意味** を揃えるとレビュアーに優しい。

---

### 「親分・子分」アナロジーで再帰を捉える
[mamo3gr#48](https://github.com/mamo3gr/arai60/pull/48)
> 部下に「インデックスi+1以降でできたsubsetの各リストに、自分が渡すpartial_subsetリストの要素が入ったものを、別途コピーしてall_subsetsに加えて、それを返して」と頼む。さらに「自分に返す時には、君が入れたpartial_subsetの値はもとに戻してね」とも頼まなければならない。

> 理想的な話をすると、関数は中を見なくても戻って来る物の想像がつくのが理想です。引数を引き回したくないと nonlocal 使うと本当は関係が不明になるので、一般に分かりにくくはなるのです。

→ nonlocal/外部変数で `result` を共有するスタイルは便利だが「関数の入出力で意図が完結しない」点で読みにくくなる。理想は **「再帰関数=部下への依頼。中身を見ずに戻り値を予測できる」** こと。pure functionalな再帰版（child_subsets に nums[start] を足したものを連結して返す）はこの観点で優れる

自分が解いたやり方だとCascadingに一番近い
```py
def generate_subsets_from(start):
    if start >= len(nums):
        return [[]]
    child = generate_subsets_from(start + 1)
    return child + [s + [nums[start]] for s in child]
```

### backtrackでのyield 
[fhiyo#51](https://github.com/fhiyo/leetcode/pull/51) / [olsen-blue#52](https://github.com/olsen-blue/Arai60/pull/52)
> indexが末尾に到達する前にyieldしているのが個人的には分かりにくい。

> 私はforがない方が好きかも。なぜそのタイミングで追加して良いのかの理由が、読めない。…選ぶ/選ばないで、再起呼び出しを分岐して行うのが対称性があって好きというのもありますね。

---

## Step3
start index 再帰版を解く
```py
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        def extend_subset_from(start):
            result.append(subset[:])
            for i in range(start, len(nums)):
                subset.append(nums[i])
                extend_subset_from(i + 1)
                subset.pop()
            
        result = []
        subset = []
        extend_subset_from(0)
        
        return result
```

### 類題
- [LC 90. Subsets II](https://leetcode.com/problems/subsets-ii/)
- [LC 77. Combinations](https://leetcode.com/problems/combinations/)
- [LC 39. Combination Sum](https://leetcode.com/problems/combination-sum/)
- [LC 40. Combination Sum II](https://leetcode.com/problems/combination-sum-ii/)
- [LC 46. Permutations](https://leetcode.com/problems/permutations/)
- [LC 47. Permutations II](https://leetcode.com/problems/permutations-ii/)
- [LC 491. Non-decreasing Subsequences](https://leetcode.com/problems/non-decreasing-subsequences/)
- [LC 784. Letter Case Permutation](https://leetcode.com/problems/letter-case-permutation/)