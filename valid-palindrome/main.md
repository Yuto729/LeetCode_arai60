A phrase is a palindrome if, after converting all uppercase letters into lowercase letters and removing all non-alphanumeric characters, it reads the same forward and backward. Alphanumeric characters include letters and numbers.

Given a string s, return true if it is a palindrome, or false otherwise.
 
Example 1:
Input: s = "A man, a plan, a canal: Panama"
Output: true
Explanation: "amanaplanacanalpanama" is a palindrome.

Example 2:
Input: s = "race a car"
Output: false
Explanation: "raceacar" is not a palindrome.

Example 3:
Input: s = " "
Output: true
Explanation: s is an empty string "" after removing non-alphanumeric characters.
Since an empty string reads the same forward and backward, it is a palindrome.

Constraints:
- 1 <= s.length <= 2 * 10^5
- s consists only of printable ASCII characters.

## Step1
- convert uppercase to lowercase
- remove non-alphanumeric characters (letters and numbers以外)
- same forward and backward

19msくらい. もうちょい早くできそう. 一個のループでかける
```py
class Solution:
    def isPalindrome(self, s: str) -> bool:
        s = s.strip()
        if not s:
            return True
        
        # remove and converting
        def convert_and_remove(s):
            preprocessed_s = []
            for c in s:
                if 'A' <= c <= 'Z':
                    i = string.ascii_uppercase.find(c)
                    preprocessed_s.append(string.ascii_lowercase[i])
                    continue
                
                if not ('0' <= c <= '9' or 'a' <= c <= 'z'):
                    continue
                
                preprocessed_s.append(c)
            
            return "".join(preprocessed_s)
        
        def check_if_parindrome(s):
            left = 0
            right = len(s) - 1
            while left < right:
                if s[left] != s[right]:
                    return False

                right -= 1
                left += 1

            return True

        
        preprocessed_s = convert_and_remove(s)
        return check_if_parindrome(preprocessed_s)
```

あまり実行時間が変わらない
- convert_to_valid_charの中身に書き方のバリエーションがあるように思える

```py
class Solution:
    def isPalindrome(self, s: str) -> bool:
        s = s.strip()
        if not s:
            return True
        
        def convert_to_valid_char(c):
            if 'A' <= c <= 'Z':
                i = string.ascii_uppercase.find(c)
                return string.ascii_lowercase[i]
         
            if not ('0' <= c <= '9' or 'a' <= c <= 'z'):
                return ""
            
            return c
            
        left = 0
        right = len(s) - 1
        while left < right:
            left_char = convert_to_valid_char(s[left])
            right_char = convert_to_valid_char(s[right])
            if left_char == "":
                left += 1
                continue

            if right_char == "":
                right -= 1
                continue
            
            if left_char != right_char:
                return False
            
            left += 1
            right -= 1
        
        return True
```

`ord`で直接変換してみた
```py
def convert_to_valid_char(c):
    if 'A' <= c <= 'Z':
        return chr(ord('a') + (ord(c) - ord('A')))
    
    if not ('0' <= c <= '9' or 'a' <= c <= 'z'):
        return ""
    
    return c
```

なかなか速くならないのでAIに聞いてみる
> Pythonでは組み込み関数（C実装）を使うのが一番速いです。
確かに忘れていた
```py
class Solution:
    def isPalindrome(self, s: str) -> bool:
        s = s.strip()
        if not s:
            return True
        
        def convert_to_valid(s):
            filtered = []
            # 組み込み関数
            for c in s.lower():
                # 組み込み関数
                if not c.isalnum():
                    continue
                
                filtered.append(c)
            return filtered

        def check_if_parindrome(s):
            left = 0
            right = len(s) - 1
            while left < right:
                if s[left] != s[right]:
                    return False

                right -= 1
                left += 1

            return True 
        left = 0
        right = len(s) - 1
        filtered = convert_to_valid(s)
        return check_if_parindrome(filtered)
```