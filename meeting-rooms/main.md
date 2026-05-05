Given an array of meeting time intervals where intervals[i] = [start_i, end_i], determine if a person could attend all meetings.

Example 1:
Input: intervals = [[0,30],[5,10],[15,20]]
Output: false

Example 2:
Input: intervals = [[7,10],[2,4]]
Output: true

Constraints:
- 0 <= intervals.length <= 10^4
- intervals[i].length == 2
- 0 <= starti < endi <= 10^6

## Step1
各intervalが重なってなければok. 重なっていたらだめということか？
わからなかったので教えてもらった
```py
class Solution:
    def canAttendMeetings(self, intervals: List[List[int]]) -> bool:
        sorted_intervals = sorted(intervals, key=lambda x: x[0])
        for i in range(1, len(intervals)):
            if sorted_intervals[i - 1][1] > sorted_intervals[i][0]:
                return False
        
        return True
```