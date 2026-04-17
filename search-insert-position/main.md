35. Search Insert Position
Given a sorted array of distinct integers and a target value, return the index if the target is found. If not, return the index where it would be if it were inserted in order.
You must write an algorithm with O(log n) runtime complexity.

Example 1:
Input: nums = [1,3,5,6], target = 5
Output: 2

Example 2:
Input: nums = [1,3,5,6], target = 2
Output: 1

Example 3:
Input: nums = [1,3,5,6], target = 7
Output: 4

Example 4:
Input: nums = [1,3,5,6], target = 4
Output: 2

Example 5:
Input: nums = [-1,3,5,6], target = 0
Output: 1

Constraints:
- 1 <= nums.length <= 10^4
- -10^4 <= nums[i] <= 10^4
- nums contains distinct values sorted in ascending order.
- -10^4 <= target <= 10^4

Approach
- bisect_left相当を実装すれば良さそう
- 閉区間で実装をした
- left > rightでループが終わるのでleftが挿入位置を表すことになる

時間計算量：O(logn)
```py
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        if not nums:
            # error
            pass
        
        left, right = 0, len(nums) - 1
        while left <= right:
            mid = (left + right) // 2
            if nums[mid] == target:
                return mid
            
            if nums[mid] < target:
                left = mid + 1
            else:
                right = mid - 1
        
        return left
```
follow up
- なぜ`left`が挿入位置になるのか？
    - `left`は「targetより小さい要素の右端の次」を常に指している
    - `right`は「targetより大きい要素の左端の前」を常に指している
    - ループ終了時に、nums[right] < target < nums[left]という関係がなりたつ

- `bisect_right` -> ある値の範囲の終端を探す(targetより大きい要素の左端の1個前を表すので)
- `bisect_left` -> ある値の最初の出現位置を探す
- 重複要素がある場合どう書く？
- 再帰で実装するパターン


- 半開区間で実装すると以下のようになる
```py
class Solution:
    def searchInsert(self, nums: List[int], target: int) -> int:
        if not nums:
            # error
            pass
        
        left, right = 0, len(nums)
        while left < right:
            mid = (left + right) // 2
            if nums[mid] == target:
                return mid
            
            if nums[mid] < target:
                left = mid + 1
            else:
                right = mid
        
        return left
```

- 再帰
```py


```