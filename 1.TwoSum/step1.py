"""
hashmapを使った解法
2重ループは避けたかったので、1重ループで完結する方法を考えるようにした.
ループ内でtargetとの差分を定数時間で探せれば良さそう => hashmapを用いる.
"""
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        nums_index_map = {}
        for i in range(len(nums)):
            nums_index_map[nums[i]] = i

        for i in range(len(nums)):
            difference_to_target = target - nums[i]
            if difference_to_target in nums_index_map and nums_index_map[difference_to_target] != i:
                return [i, nums_index_map[difference_to_target]]
