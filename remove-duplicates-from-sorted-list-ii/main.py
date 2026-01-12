# 修正版

from typing import Optional
# こちらのコメントを受けて:  https://github.com/Yuto729/LeetCode_arai60/pull/11#discussion_r2572730796


class Solution:
    def deleteDuplicates(self, head: Optional[ListNode]) -> Optional[ListNode]:
        dummy = ListNode()
        dummy.next = head
        previous = dummy
        current = head

        while current is not None:
            if current.next is None or current.val != current.next.val:
                previous = current
                current = current.next
                continue

            value_to_delete = current.val

            while current is not None and current.val == value_to_delete:
                current = current.next

            previous.next = current

        return dummy.next
