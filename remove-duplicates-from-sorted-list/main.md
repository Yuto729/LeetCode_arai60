## Step1
1.
重複をsetを用いて判定する.
重複がある場合, previousとcurrentのポインタをずらす. 

```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        seen = set()
        previous = None
        current = head
        while current is not None:
            if current.val in seen:
                previous.next = current.next
                current = current.next
                continue
            
            seen.add(current.val)
            previous = current
            current = current.next
        
        return head
```
2.
空間計算量がO(1)の解法.
昇順に並んでいるので, 1つ後ろのノードとのみ比較すればいい.

```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        if head is None:
            return None

        node = head
        while node is not None and node.next is not None:
            if node.val == node.next.val:
                # next nodeと値が同じ時はnodeを進めない.
                node.next = node.next.next
                continue

            node = node.next
        
        return head
```

## Step2
https://discord.com/channels/1084280443945353267/1195700948786491403/1196399353116499970
このような解き方がある. Step1の二個目の解法を二重のwhileに書き直したもの.


```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        node = head
        while node is not None:
            while node.next is not None and node.val == node.next.val:
                node.next = node.next.next

            node = node.next
        
        return head
```
また, 
https://github.com/docto-rin/leetcode/pull/3
上記を参考に, while => 再帰に書き換えてみる.
whileの中身をそのままマッピングしていく感じ.
```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        if head is None or head.next is None:
            return head
        
        if head.val == head.next.val:
            head.next = head.next.next
            return self.deleteDuplicates(head)
        
        head.next = self.deleteDuplicates(head.next)
        return head

```
こう書くこともできる.
```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        if head is None or head.next is None:
            return head
        
        # head.nextに入るのは, それ以降を再帰的に処理したノードの列.
        head.next = self.deleteDuplicates(head.next)
        if head.val == head.next.val:
            # 先頭を飛ばす.
            return head.next
        
        # 飛ばさない.
        return head
```


## Step3
苦手な再帰で練習.

```py
class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        if head is None or head.next is None:
            return head
        
        if head.val == head.next.val:
            head.next = head.next.next
            return self.deleteDuplicates(head)
        
        head.next = self.deleteDuplicates(head.next)
        return head

```