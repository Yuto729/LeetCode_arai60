class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        num_to_index = {}

        for i in range(len(nums)):
            difference_to_target = target - nums[i]

            if difference_to_target in num_to_index:
                return [i, num_to_index[difference_to_target]]
            
            num_to_index[nums[i]] = i
        
        raise ValueError("no combination is found.")
