## Step1
自力で解いてみる.
remove-duplicates-from-sorted-list-iiと同じようにsetを用いて解こうとしたが, setを使うと重複の１つ目を削除することができず断念.
https://leetcode.com/problems/remove-duplicates-from-sorted-list-ii/solutions/7002012/simple-solution-by-harshita_114-2gqn/
を参考にcurrentとpreviousを定義して, currentが次のノードの値と等しいとき, 現在も含めて重複がなくなるまでポインタをスキップする（内側のwhileループ）.


```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        dummy = ListNode()
        dummy.next = head
        previous = dummy
        current = head
        while current is not None:
            if current.next is not None and current.next.val == current.val:
                while current.next is not None and current.next.val == current.val:
                    current = current.next
                
                previous.next = current.next
                current = current.next
                continue
            
            previous = current
            current = current.next
        
        return dummy.next
```

## Step2
①
https://github.com/docto-rin/leetcode/pull/4/files
などを参考に重複を削除する部分を関数化してみる.

```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        dummy = ListNode()
        dummy.next = head
        previous = dummy
        current = head
        def deleteCurrentDuplicates(node):
            while node.next is not None and node.val == node.next.val:
                node = node.next

            return node.next
        
        while current is not None:
            if current.next is not None and current.next.val == current.val:
                current = deleteCurrentDuplicates(current)
                
                previous.next = current
                continue
            
            previous = current
            current = current.next
        
        return dummy.next
```

②
以下の部分で条件が重複してしまっているのが気持ちが悪い.
```py
if current.next is not None and current.next.val == current.val:
    while current.next is not None and current.next.val == current.val:
```
https://github.com/hiroki-horiguchi-dev/leetcode/pull/4/files#r2389672135
上記のコメントを参考に以下のように直すと, 回避できるがわかりやすくなったかというと?
```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        dummy = ListNode()
        dummy.next = head
        previous = dummy
        current = head
        while current is not None:

            # 重複しないケースを先に処理してcontinue
            if current.next is None or current.next.val != current.val:
                previous = current
                current = current.next
                continue

            while current.next is not None and current.next.val == current.val:
                    current = current.next
                
            previous.next = current.next
            current = current.next
        
        return dummy.next
```

③
sigle loopで解いてみる.
参考.
https://github.com/docto-rin/leetcode/pull/4/files#diff-2bdfe1140252df4bf36c06f29251eeade51991cec8bee544c92c5b27c63cfc7aR144
https://github.com/yas-2023/leetcode_arai60/pull/4/files#diff-65d8e3bc3a72aa32549ea5fdbe2ff4f6482ea25095c17f8309a39a6c79c8057eR6
```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        dummy = ListNode()
        dummy.next = head
        previous = dummy
        current = head

        # 記録用
        val_to_remove = None
        while current is not None:
            if current.val == val_to_remove:
                # 重複中
                previous.next = current.next
                current = current.next
                continue

            elif current.next is not None and current.next.val == current.val:
                # 重複の始まり
                val_to_remove = current.val
                current = current.next
                continue
            
            previous = current
            current = current.next
        
        return dummy.next
```


## Step3
```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        dummy = ListNode()
        dummy.next = head
        previous = dummy
        current = head

        def deleteCurrentDuplicates(node):
            while node.next is not None and node.next.val == node.val:
                node = node.next

            return node.next
        
        while current is not None:
            if current.next is not None and current.next.val == current.val:
                current = deleteCurrentDuplicates(current)
                previous.next = current
                continue
            
            previous = current
            current = current.next
        
        return dummy.next
```