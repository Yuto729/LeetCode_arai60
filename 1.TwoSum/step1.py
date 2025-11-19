"""
hashmapを使った解法
2重ループは避けたかったので、1重ループで完結する方法を考えるようにした.
ループ内でtargetとの差分を定数時間で探せれば良さそう => hashmapを用いる.
"""
class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        nums_index_map = {}
        for i in range(len(nums)):
            # 同じ数字がnumsに含まれている場合を考えて, valueをlistにしたほうが良かったのではとAcceptしたあとに思ったが, 
            # 組み合わせは1通りでいいので, dictには同じ数字の一番最後のindexだけ記録しておけばいいと気づいた.
            nums_index_map[nums[i]] = i

        for i in range(len(nums)):
            difference_to_target = target - nums[i]
            if difference_to_target in nums_index_map and nums_index_map[difference_to_target] != i:
                return [i, nums_index_map[difference_to_target]]
