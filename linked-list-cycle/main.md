## Step1
hashmap, setを使おうと考え, 以下のように書いたが同じ数字がサイクル外で登場することパターンを解決できず...

↓間違い
```py
class Solution:
    def hasCycle(self, head: Optional[ListNode]) -> bool:
        visited = set()
        
        while head is not None:
            val = head.val
            if val in visited:
                return True
            
            visited.add(val)
            head = head.next

        return False
```

以下を見ると、nodeを直接setに追加すれば解決できる.
オブジェクトの等価判定ができるのを忘れてた. 同一インスタンスならイコールになる.

refs. https://discord.com/channels/1084280443945353267/1195700948786491403/1195944696665604156

1回目のAccept
```py
class Solution:
    def hasCycle(self, head: Optional[ListNode]) -> bool:
        visited = set()
        
        while head is not None:
            if head in visited:
                return True
            
            visited.add(head)
            head = head.next

        return False
```

## Step2

refs. https://leetcode.com/problems/linked-list-cycle/solutions/6086375/video-using-two-pointers-by-niits-yqeh/
https://docs.google.com/document/d/11HV35ADPo9QxJOpJQ24FcZvtvioli770WWdZZDaLOfg/edit?tab=t.0#heading=h.2k4z0wt6ytf9

グラフの閉路を検出するアルゴリズムを調べてみると, 上記の解法はフロイドの循環検出法と言うらしいがslow, fastポインタは普通知らないのでsetを使って書くほうが無難そう.
こちらはfolow upにある"Can you solve it using O(1) (i.e. constant) memory?"への解答になっている.

```py
class Solution:
    def hasCycle(self, head: Optional[ListNode]) -> bool:
        fast = head
        slow = head

        while fast and fast.next:
            
            fast = fast.next.next
            slow = slow.next

            if fast == slow:
                return True

        return False
```

## Step3
https://github.com/tk-hirom/Arai60/pull/1/files/88442bc8f689042f3745e45982ec2feb2aab1c84#r1641231416
書くとしたらこっちを模範解答にしたほうが良いと思った.

```py
class Solution:
    def hasCycle(self, head: Optional[ListNode]) -> bool:
        visited = set()

        while head is not None:
            if head in visited:
                return True

            visited.add(head)
            head = head.next
        
        return False
```
