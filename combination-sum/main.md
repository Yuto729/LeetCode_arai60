Given an array of distinct integers candidates and a target integer target, return a list of all unique combinations of candidates where the chosen numbers sum to target. You may return the combinations in any order.

The same number may be chosen from candidates an unlimited number of times. Two combinations are unique if the frequency of at least one of the chosen numbers is different.

The test cases are generated such that the number of unique combinations that sum up to target is less than 150 combinations for the given input.
 

Example 1:
Input: candidates = [2,3,6,7], target = 7
Output: [[2,2,3],[7]]
Explanation:
2 and 3 are candidates, and 2 + 2 + 3 = 7. Note that 2 can be used multiple times.
7 is a candidate, and 7 = 7.
These are the only two combinations.

Example 2:
Input: candidates = [2,3,5], target = 8
Output: [[2,2,2,2],[2,3,3],[3,5]]

Example 3:
Input: candidates = [2], target = 1
Output: []

Constraints:
- 1 <= candidates.length <= 30
- 2 <= candidates[i] <= 40
- All elements of candidates are distinct.
- 1 <= target <= 40

## Step1
Approach
ex.2で考える。最初に2を選ぶと、残りは6である。[2,3,5]から6を作る組み合わせを数えればよい。再帰的に解けそう。重複を排除する仕組みが必要だが、組み合わせに値を追加するときに追加した値以降しか次に追加できないようにすれば重複を排除できそう

時間計算量 -> O(N^(T/M + 1))
- N = len(candidates)
- T = target
- M = candidatesの最小値
再帰木で考えると、各ノードで最大N個の枝に分岐し、深さは最大T/Mになる。よってノード数はO(N^(T/M + 1)). 各葉でcomb[:]のコピーにO(T/M)かかるが指数項に吸収される

空間計算量: O(T/M)

23分くらい
```py
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        comb = []
        result = []
        def backtrack(target, start):
            if target < 0:
                return

            if target == 0:
                result.append(comb[:])
                return

            for i in range(start, len(candidates)):
                comb.append(candidates[i])
                backtrack(target - candidates[i], i)
                comb.pop()
        
        backtrack(target, 0)
        return result
```

- target - candidates[i] < 0となったらそれ以降のiを探索する必要がないので枝刈りができる
candidates全要素が小さく、targetが大きい場合には枝刈りをしても探索回数は変わらない（ex. [2,3,5], taget=40）
候補にtargetより大きい値が混ざっているケースでは高速化される
```py
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        comb = []
        result = []
        # あらかじめ並べ替えておく
        candidates.sort()
        def backtrack(target, start):
            if target == 0:
                result.append(comb[:])
                return

            for i in range(start, len(candidates)):
                # ここで枝刈りをする
                if target - candidates[i] < 0:
                    break

                comb.append(candidates[i])
                backtrack(target - candidates[i], i)
                comb.pop()
        
        backtrack(target, 0)
        return result
```

iterativeでも解いてみる
- 時間計算量: 同じ
- 空間計算量: O(N^(T/M) * T/M) スタックに同時に乗る要素数の最悪見積りは、各深さで最大N通りに分岐するので「フロンティア」のサイズはO(N^(T/M))（=葉の数のオーダー）。各要素が長さO(T/M)のlistを持つので, Space: O(N^(T/M) · T/M)

```py
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        result = []
        candidates.sort()
        stack = [(0, [], target)]
        while stack:
            start, comb, target = stack.pop()
            if target == 0:
                result.append(comb[:])
                continue

            for i in range(start, len(candidates)):
                if target - candidates[i] < 0:
                    break

                stack.append((i, comb + [candidates[i]], target - candidates[i]))

        return result
```

その他の解法
- bottom-up DP: 全組み合わせを列挙
- 採用 / 不採用の二分再帰
- Cascading

bottom-up DP

- Time: バックトラックと同じ。全組み合わせを列挙するから
- Space: O(組み合わせ総数 * T/M) バックトラック版より明確に大きい

本問題を無制限ナップザックとみなした解法。
```py
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        # dp[t] = targetがtになる組み合わせのリスト
        dp = [[] for _ in range(target + 1)]
        dp[0] = [[]]
        # 外ループをcandidatesにすることで、重複組み合わせを排除できる。同じcは「使い始めた以降」しか後ろにこない
        for candidate in candidates:
            for t in range(2, target + 1):
                if candidate > t:
                    continue

                for comb in dp[t - candidate]:
                    dp[t].append(comb + [candidate]) # 更新則は「candidateが最後にくる場合」について考えているので、candidateの遷移が一方向であればcandidateを遡って重複することがない

        return dp[target]
```

二分再帰
for loopではなく、各候補について「使う / 使わない」の２択で分岐する。
0-1 Knapsackと同じテンプレ
```py
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        def enumerate_combinations_from(i, target):
            if target == 0:
                result.append(comb[:])
                return
            
            if i == len(candidates) or target < 0:
                return
            
            # 使う
            comb.append(candidates[i])
            enumerate_combinations_from(i, target - candidates[i])
            comb.pop()
            # 使わない
            enumerate_combinations_from(i + 1, target)
        
        result = []
        comb = []
        enumerate_combinations_from(0, target)
        return result
```

Follow-up
- 重複を含む場合

## Step2

### 再帰 → スタック変換のメンタルモデル
- https://discord.com/channels/1084280443945353267/1233603535862628432/1238707903196565546
> 再帰をスタックに直すときにどうするかというので、箱に「これからしなきゃいけない内容の書かれた紙」を入れていって箱が空になったら終わりという説明をしたことがあります。

スタックは「**TODOの紙が入った箱**」。1枚引いて中身を見て、必要なら新しい紙を書いて箱に入れる。箱が空になったら終了。再帰関数の引数 = 紙に書く情報 (index, total, combination など)。このイメージを持つと、再帰 ↔ stackループの書き換えが機械的にできるようになる。

### 分類の網羅という視点（バックトラックの本質）
[fhiyo#52](https://github.com/fhiyo/leetcode/pull/52#discussion_r1690161771)
> [A, A] まで使うことが確定していて B 以降しか使ってはいけないという状況下で、
> 1. B を一つ使うか、C 以降しか使ってはいけないか、に分岐する。
> 2. B の使う数を列挙して分岐し、C 以降しか使ってはいけないに遷移する。
> 3. 次の1個が、B, C, D, E, F... である場合に分岐する。

バックトラックの本質は「**抜け漏れ・重複なく状態空間を分類すること**」。本問の3つの解法（二分版 / B個数列挙版 / for-loop版）はそれぞれこの1/2/3に対応している。同じ問題でも「どう分類するか」で再帰の形が変わる。

二分版とfor-loop版はStep1で解いたが、B個数列挙版は解いていない。下記のようになる
- 「インデックスiの値を0個, 1個, ... k個まで使う」を全パターン列挙してからi+1に進む
```py
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        result = []
        comb = []

        def enumerate_combinations_from(i, remaining):
            if remaining == 0:
                result.append(comb[:])
                return
            
            if i == len(candidates):
                return
            
            # candidates[i]を使う個数kを0,1,2,...,kと列挙
            count = 0
            while count * candidates[i] <= remaining:
                enumerate_combinations_from(i + 1, remaining - count * enumerate[i])
                comb.append(candidates[i])
                count += 1
            # combを元に戻す
            for _ in range(count):
                comb.pop()
            
            enumerate_combinations_from(0, target)
            return result
```

### 「使う/使わない」二分再帰の非対称性
[olsen-blue#53](https://github.com/olsen-blue/Arai60/pull/53#discussion_r1547940000)
> 前者の再帰呼び出しが抱え込んで担当している分類の数（nums[index]を 1 ~ 最大数 まで追加する場合をすべて網羅）が、後者の再帰呼び出し（nums[index]を0個追加、という１つのみの分類ケースを担当）と比較して圧倒的に多い

`helper(i, target-c)`（使う、iは据え置き）と `helper(i+1, target)`（使わない）は**対称ではない**。前者がi=据え置きでループする間に「c_iを1個・2個・3個…使うケース」を全て担当している。Combination Sumの「無制限再利用」が形に表れたところ。

### 0-1ナップザック化のテクニック
[olsen-blue#53](https://github.com/olsen-blue/Arai60/pull/53)
> for sum_value in range(candidate, target + 1): を for sum_value in range(target, candidate - 1, - 1):と逆向きのループで書くと、個数無制限ではなくなって個数1つだけの場合になりそう

DPの内側ループの**向き**が、無制限ナップザック vs 0-1ナップザックを切り替える
- 昇順 (`range(c, T+1)`): 同じcを複数回使える → Unbounded（本問・LC 518）
- 降順 (`range(T, c-1, -1)`): 同じcは1回まで → 0-1（LC 416 Partition Equal Subset Sum）

[→Mike0121#1](https://github.com/Mike0121/LeetCode/pull/1#discussion_r1577902430)
> 変化のある方を比較演算子の左側に置く方がわかりやすい

`len(candidates) <= index` より `index == len(candidates)`

### 降順ソートで枝刈りを早める
[naoto-iwase#53](https://github.com/naoto-iwase/leetcode/pull/53)
> candidatesをあらかじめ降順にソートしておくと実行時間が2倍以上速くなった

二分再帰で、枝刈り `total + n > target` で打ち切るとき、**大きい値から試すと早期にtargetを超える**ので失敗判定が速い。昇順だと小さい値で長く伸びてから刈られる。最悪オーダーは同じだが定数倍に効く

### yield/generator
[fhiyo#52](https://github.com/fhiyo/leetcode/pull/52)
```py
def generate_combinations(combination, total, start) -> Iterator[list[int]]:
    if total == target:
        yield combination
        return
    for i in range(start, len(candidates)):
        if total + candidates[i] > target: break
        yield from generate_combinations(combination + [candidates[i]], total + candidates[i], i)
```
本問では結局listに変換するので旨味は薄いが、**遅延評価**できるので「先頭K個だけ欲しい」用途ではメモリ効率が良い。`yield from` で再帰を素直に書ける。


## Step3
for-loop版で解く。
```py
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        candidates.sort()
        def enumerate_combinations_from(start, remaining):
            if remaining == 0:
                result.append(comb[:])
                return

            for i in range(start, len(candidates)):
                if candidates[i] > remaining:
                    break

                comb.append(candidates[i])
                enumerate_combinations_from(i, remaining - candidates[i])
                comb.pop()
        
        result = []
        comb = []
        enumerate_combinations_from(0, target)
        return result

```
## 類題
- [40. Combination Sum II](https://leetcode.com/problems/combination-sum-ii/) — 重複入力・各要素1回まで
- [216. Combination Sum III](https://leetcode.com/problems/combination-sum-iii/) — 1〜9から k 個選んで n を作る
- [377. Combination Sum IV](https://leetcode.com/problems/combination-sum-iv/) — 順列扱い・個数だけ（1次元DP）
- [518. Coin Change II](https://leetcode.com/problems/coin-change-ii/) — 個数版・無制限ナップザック
- [322. Coin Change](https://leetcode.com/problems/coin-change/) — 最小個数
- [416. Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/) — 0-1ナップザック
- [78. Subsets](https://leetcode.com/problems/subsets/) / [90. Subsets II](https://leetcode.com/problems/subsets-ii/) — 同系統のbacktracking
- [46. Permutations](https://leetcode.com/problems/permutations/) — 次に解く問題系統
- [22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/)