## Step1

Linked List Cycle 1と同じようにsetを利用して解く.
```py
class Solution:
    def detectCycle(self, head: Optional[ListNode]) -> Optional[ListNode]:
        visited = set()
        node = head
        while node is not None:
            if node in visited:
                return node

            visited.add(node)
            node = node.next
        
        return None
```

Floydの解法で解いてみる.
Linked List Cycle 1と異なり, サイクルを検出するだけでなく入口を探さないといけないので入口検出のループがある.（追いついた地点は入口とは限らないため）
入口検出では, slow, fastポインタを同じ速度で動かし続ければいつかサイクルの入口でぶつかる.
時間計算量: O(N).
入口検出ステップで, サイクルを何周もしても計算量は増えない？
```py
class Solution:
    def detectCycle(self, head: Optional[ListNode]) -> Optional[ListNode]:
        fast = head
        slow = head
        while fast and fast.next:
            slow = slow.next
            fast = fast.next.next
            if fast == slow:
                break
        
        else: return None

        fast = head
        while fast != slow:
            fast = fast.next
            slow = slow.next
        
        return slow
```


## Step2

Floydの解法を綺麗にする.
https://github.com/docto-rin/leetcode/pull/2/
https://github.com/Kaichi-Irie/leetcode-python/pull/20#discussion_r2341229316
変数名などを参考にした.

また、以下でサイクルを検出する部分を関数化することが提案されていたが、以下のようなメリットがあると思われる.
- サイクルがあるかどうかのフラグや`while else`構文を回避できる. 前者は制御の流れをわかりにくくし, `while else`構文は
あまりつかったことがない.
- サイクルが存在すれば衝突点を返し, 存在しなければNoneを返すシンプルな実装にできる.

https://github.com/nanae772/leetcode-arai60/pull/3#discussion_r2317374235

```py
class Solution:
    def detectCycle(self, head: Optional[ListNode]) -> Optional[ListNode]:
        def find_intersection(node):
            slow = head
            fast = head

            while fast is not None and fast.next is not None:
                slow = slow.next
                fast = fast.next.next
                
                # デフォルトでは, __eq__メソッドではオブジェクトの等価性を見ているので `==` で記述しても同じだが以下のように記述するほうが厳密. `is`はポインタの比較？
                if slow is fast:
                    return slow
                
            return None

        intersection = find_intersection(head)
        if intersection is None:
            return None

        from_start = head
        from_intersection = intersection
        while from_start is not from_intersection:
            from_start = from_start.next
            from_intersection = from_intersection.next

        return from_start
```


## Step3
```py
class Solution:
    def detectCycle(self, head: Optional[ListNode]) -> Optional[ListNode]:
        def find_intersection(node):
            fast = node
            slow = node
            while fast is not None and fast.next is not None:
                slow = slow.next
                fast = fast.next.next
                if fast is slow:
                    return slow
                
            return None
        
        intersection = find_intersection(head)
        if intersection is None:
            return None
        
        from_start = head
        from_intersection = intersection
        while from_start is not from_intersection:
            from_start = from_start.next
            from_intersection = from_intersection.next
        
        return from_start
```