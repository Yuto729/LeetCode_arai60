## Step1
stackに全ノードをためておき, 今度はstackが空になるまで後ろにつなげていけばいい.
時間計算量はO(N)になる.
時間: 10分くらい.

```py
class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        node = head
        stack = []
        while node is not None:
            stack.append(node)
            node = node.next
        
        dummy = ListNode()
        tail = dummy
        while stack:
            tail.next = stack.pop()
            tail.next.next = None
            tail = tail.next

        return dummy.next
```
`tail`より`reversed_node`あたりが良いか？

# Step2 follw up, 他の人のコードを読む.

次にフォローアップで再帰を用いて書いてみる.
以下のように記述したが間違い. head.next以降を逆順に並び替えたものの後ろに加えるという発想はあっていたが, これだと末尾を返すことになってしまう.
```py
class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        if head is None or head.next is None:
            return head

        reversed_head = self.reverseList(head.next)
        head.next = None
        reversed_head.next = head
        return reversed_head
```

https://discord.com/channels/1084280443945353267/1231966485610758196/1239417493211320382
https://github.com/goto-untrapped/Arai60/pull/27/files
再帰については２つの考え方がある.
1. 頭からn番目まで逆順にしたリストを渡して, 全体が逆順になったものを返却してもらう.
2. 何も渡さず, n番目以降を逆順にしたものを返却してもらう.

1は
2はheadとhead.nextに分離して, head.nextを再帰的に逆順にしたもののtailにheadをくっつける. 最終的には逆順リストの頭を返さないといけないので, 再帰関数ではheadも返すようにし, 最終的にこれを返却する.

```py
class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        def reverseListHelper(node):
            # nodeが最後の要素のとき.
            if node.next is None:
                return node, node
            
            node_next = node.next
            node.next = None
            new_head, new_tail = reverseListHelper(node_next)
            new_tail.next = node
            
            return new_head, node
        
        # edge case: 空リストのときは先に処理する.
        if not head:
            return head
        
        head, _tail = reverseListHelper(head)
        return head
```

```py
class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        def reverseListHelper(node):
            # nodeが最後の要素のとき.
            if node.next is None:
                return node, node
            
            node_next = node.next
            # node.next = None
            new_head, new_tail = reverseListHelper(node_next)
            # こっちのほうがいいかも. 非破壊.
            node.next = None
            new_tail.next = node
            
            return new_head, node
        
        # edge case: 空リストのときは先に処理する.
        if not head:
            return head
        
        head, _tail = reverseListHelper(head)
        return head
```

また, `new_tail`は`node.next`になるので, 以下のように書ける.
```diff
@@ def reverseListHelper(node): 
     if node.next is None:
-       return node, node
+       return node

-    new_head, new_tail = reverseListHelper(node_next)
+    new_head = reverseListHelper(node_next)
+    node.next.next = node
     node.next = None
-    new_tail.next = node
-    return new_head, node
+    return new_head
```

また, 2のやり方は以下のように書ける.
これは**末尾再帰**
```py
class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        def reverseListHelper(reversed_head, rest_node):
            if rest_node.next is None:
                rest_node.next = reversed_head
                return rest_node
            
            rest_node_next = rest_node.next
            rest_node.next = reversed_head
            return reverseListHelper(rest_node, rest_node_next)

        if not head:
            return head

        return reverseListHelper(None, head) 
```


空間計算量がO(1)になるやりかたもある. 

```py
class Solution:
    def reverseList(self, head: Optional[ListNode]) -> Optional[ListNode]:
        node = head
        # 新たにheadを定義. これが返り値になる.
        head = None

        while node is not None:
            # node.nextを一時保存する.
            temp_node = node.next
            # 現在のnodeの次にheadが来るようにする.
            node.next = head
            # headのポインタを更新.
            head = node
            # nodeを次に進める.
            node = temp_node

        return head
```
### iterativeとrecursionの比較
iterative版 => ポインタを一つずつ進め, 反転済み部分にconcatしながら一つの連結リストを作成する操作. foldl（左畳み込み）に相当する.
2の再帰（末尾再帰）=> iterative版と同じロジック. 関数間 / ループ間で渡すのはすでに逆順にした部分と残りの部分.
1の再帰 => ポインタを一つずつ進め, 反転していない前半の部分を反転済みの後半の部分にくっつける操作. すなわちfoldrに相当. 