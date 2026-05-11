## Step1

LinkedListなのでlen関数では長さがわからず, forループは使えない => whileを使って1桁ずつ足していく.
各桁の足し算で, 現在のノードに格納する数字は合計値を10で割った余りになる. 桁上がりを保持し, 次のノードの計算で加えるようにする.

詰まったところ
- whileの条件文にcarryも入れるところ.
- `l2_current_val = l1.val if l2 else 0`と間違えて書いているのに気づくのに時間がかかった.

dummy nodeで初期化してcurrentとする（番兵？）のは前に他の問題で見たことがあった.

時間計算量: O(max(m, n)). m: l1の長さ, n: l2の長さ
空間計算量: O(1) ? O(n) ?
```py
class Solution:
    def addTwoNumbers(
        self, l1: Optional[ListNode], l2: Optional[ListNode]
    ) -> Optional[ListNode]:

        carry = 0
        dummy_node = ListNode()
        current = dummy_node
        
        while l1 or l2 or carry:
            l1_current_val = l1.val if l1 else 0
            l2_current_val = l2.val if l2 else 0

            new_node = ListNode((l1_current_val + l2_current_val + carry) % 10)
            current.next = new_node
            current = new_node

            carry = (l1_current_val + l2_current_val + carry) // 10
            
            l1 = l1.next if l1 else None
            l2 = l2.next if l2 else None
        
        return dummy_node.next
```


## Step2
他の解法
- 再帰を用いる. 確かにwhileで書けるなら再帰を用いても書けそう.


```py
# 再帰を用いた解法.
class Solution:
    def addTwoNumbers(
        self, l1: Optional[ListNode], l2: Optional[ListNode]
    ) -> Optional[ListNode]:
        
        def add_two_single_numbers(l1, l2, carry, current):
            if not l1 and not l2 and not carry:
                return
            
            l1_current_val = l1.val if l1 else 0
            l2_current_val = l2.val if l2 else 0

            sum = l1_current_val + l2_current_val + carry
            
            carry = sum // 10
            
            current.next = ListNode(sum % 10)
            current = current.next
            l1_next = l1.next if l1 else None
            l2_next = l2.next if l2 else None

            add_two_single_numbers(l1_next, l2_next, carry, current)

        carry = 0
        dummy_node = ListNode()
        current = dummy_node
        
        add_two_single_numbers(l1, l2, carry, current)
        
        return dummy_node.next
```

Step1の解答を綺麗にする.
現在のノードの値と次のノードを返す関数を作成. refs. https://github.com/docto-rin/leetcode/pull/5/filesm/docto-rin/leetcode/pull/5/files
三項演算子について, こちらの議論が非常に参考になった(refs. https://github.com/yas-2023/leetcode_arai60/pull/5/files#r2386273530)

```py
class Solution:
    def addTwoNumbers(
        self, l1: Optional[ListNode], l2: Optional[ListNode]
    ) -> Optional[ListNode]:

        def get_current_val_and_next_node(node):
            if not node:
                return 0, None
            
            return node.val, node.next
            
                
        carry = 0
        dummy_node = ListNode()
        current = dummy_node

        while l1 or l2 or carry:
            l1_val, l1 = get_current_val_and_next_node(l1)
            l2_val, l2 = get_current_val_and_next_node(l2)

            sum = l1_val + l2_val + carry

            new_node = ListNode(sum % 10)
            current.next = new_node
            current = new_node
            
            carry = sum // 10
        
        return dummy_node.next

```


## Step3
```py
class Solution:
    def addTwoNumbers(
        self, l1: Optional[ListNode], l2: Optional[ListNode]
    ) -> Optional[ListNode]:

        def get_current_val_and_next_node(node):
            if not node:
                return 0, None
            
            return node.val, node.next
            
                
        carry = 0
        dummy_node = ListNode()
        current = dummy_node

        while l1 or l2 or carry:
            l1_val, l1 = get_current_val_and_next_node(l1)
            l2_val, l2 = get_current_val_and_next_node(l2)

            sum = l1_val + l2_val + carry

            new_node = ListNode(sum % 10)
            current.next = new_node
            current = new_node
            
            carry = sum // 10
        
        return dummy_node.next
```
