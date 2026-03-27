class Solution:
    def addTwoNumbers(
        self, l1: Optional[ListNode], l2: Optional[ListNode]
    ) -> Optional[ListNode]:
        
        def get_current_val_and_next_val(node):
            if not node:
                return 0, None
            
            return node.val, node.next

        carry = 0
        dummy_node = ListNode()
        node = dummy_node

        while l1 is not None or l2 is not None or carry:
            l1_val, l1 = get_current_val_and_next_val(l1)
            l2_val, l2 = get_current_val_and_next_val(l2)

            sum_val = l1_val + l2_val + carry
            carry = sum_val // 10

            new_node = ListNode(sum_val % 10)
            node.next= new_node
            node = new_node
        
        return dummy_node.next