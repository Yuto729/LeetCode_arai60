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
