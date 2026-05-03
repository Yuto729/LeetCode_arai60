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

Follow-up                                                   
- nums に重複がある場合（Subsets II, LC 90）はどう拡張しますか？
    - sort
    - 同階層で同じ値は１度だけ使うようにする