## Step1
ナイーブな実装. '@'で分割してlocal nameを条件に合わせて整形する.
時間計算量: O(m*n) m: emailsの長さ, n: emailの平均長さ
```py
class Solution:
    def numUniqueEmails(self, emails: List[str]) -> int:
        def parse_local_name(local_name):
            if local_name[0] == '+':
                raise ValueError("local name start with plus operator.")

            parsed_local_name = []
            for c in local_name:
                if c == '.':
                    continue
                
                if c == '+':
                    break
                
                parsed_local_name.append(c)
            return "".join(parsed_local_name)

        unique_emails = set()
        for email in emails:
            local_name, domain_name = email.split('@')
            if not local_name or not domain_name:
                continue
            
            parsed_local_name = parse_local_name(local_name)
            parsed_email = parsed_local_name + '@' + domain_name
            unique_emails.add(parsed_email)

        return len(unique_emails)
```

まとめられる部分をまとめ, 処理を簡略化する.
```py
class Solution:
    def numUniqueEmails(self, emails: List[str]) -> int:
        def parse_local_name(local_name):
            if local_name[0] == '+':
                raise ValueError("local name start with plus operator.")

            return local_name.split('+')[0].replace('.', '')

        unique_emails = set()
        for email in emails:
            local_name, domain_name = email.split('@')
            if not local_name or not domain_name:
                continue
            
            if not domain_name.endswith(".com"):
                continue
            
            parsed_local_name = parse_local_name(local_name)
            unique_emails.add(parsed_local_name + '@' + domain_name)

        return len(unique_emails)
```
`+`による文字列の結合はオブジェクトの再生成を伴うので効率が悪い. ユニークな数がわかればいいのでタプルをキーにすれば良さそう. 
平均7 ms => 3 msほどに改善
```diff
--- unique_emails.add(parsed_local_name + '@' + domain_name)
+++ unique_emails.add((parsed_local_name, domain_name))
```

## Step2 他の人のコード・コメントなどを読む
https://github.com/SuperHotDogCat/coding-interview/pull/30#discussion_r1646552062
RFC上は@を複数持てるので, 末尾から数えて最初の@でsplitするようにしたい.

また, ユースケースの想定が重要である. 
https://github.com/Yoshiki-Iwasa/Arai60/pull/13#discussion_r1649832719
https://github.com/seal-azarashi/leetcode/pull/14#discussion_r1676988400
https://github.com/SuperHotDogCat/coding-interview/pull/30#discussion_r1646552062
> メールアドレスはユーザーから渡されるものである可能性が高く、ゴミを渡されたときに落ちるプログラムにしてはいけない

想定ユースケース
ユーザーから受け取ったEmailアドレスをまとめてバリデーションしたい.

以下のようなユースケースを考えてみた.
1. まとめてメールを送信したい.
2. まとめてアカウントの登録処理を行いたい.
1の場合, 不正な入力があったときもログには出してほしいが例外は投げてほしくない.
2の場合, 例えばDBにグループテーブルがあり, なるべくグループ全員分を揃えて一回のInsert処理で整合性を確保したいときは不正なメールに対して例外を出してほしいが, 個人アカウントをバッチで登録処理するようなケースでは,不正な入力はログを出す（あるいはユーザーに通知する）はしたいが例外は投げてほしくない.


https://github.com/docto-rin/leetcode/pull/14/files#r2416453019
>同様に、domain_name[:-4]もみるべきですね。
上記は以下の仕様に対応している. こちらもバリデーションに加えたい.
>Domain names must contain at least one character before ".com" suffix.
```py
class Solution:
    def numUniqueEmails(self, emails: List[str]) -> int:
        unique_emails = set()
        for email in emails:
            local_name, domain_name = email.split('@', maxsplit=1)
            if not local_name or not domain_name:
                continue

            if not domain_name.endswith(".com"):
                continue
            
            if len(domain_name) <= 4:
                # @とsuffixの間に１文字もないとき
                continue

            if local_name[0] == '+':
                continue
            
            parsed_local_name = local_name.split('+')[0].replace('.', '')
            unique_emails.add((parsed_local_name, domain_name))

        return len(unique_emails)
```

https://github.com/plushn/SWE-Arai60/pull/14#discussion_r2051712557
try-exceptで終了しないように書くのも良いと思った.


最後にsplitを使わずに1文字ずつの逐次処理で書いてみる.

```py
class Solution:
    def numUniqueEmails(self, emails: List[str]) -> int:
        def parse_email(email):
            parsed_email = []
            in_domain = False
            first_plus_appeared = False
            for c in email:
                if in_domain:
                    parsed_email.append(c)
                    continue

                if c == '@':
                    in_domain = True
                    parsed_email.append('@')
                    continue

                if first_plus_appeared:
                    continue

                if c == '.':
                    continue
                
                if c == '+':
                    first_plus_appeared = True
                    continue

                parsed_email.append(c)
            return "".join(parsed_email)

        unique_emails = set()
        for email in emails:
            parsed_email = parse_email(email)
            unique_emails.add(parsed_email)
        
        return len(unique_emails)
```
なるべく制御フラグ`in_domain`を削除して以下のようにも書ける.

```py
class Solution:
    def numUniqueEmails(self, emails: List[str]) -> int:
        def parse_email(email):
            parsed_email = []
            first_plus_appeared = False
            for i, c in enumerate(email):
                if c == '@':
                    return "".join(parsed_email) + email[i:]

                if c == '.':
                    continue
                
                if c == '+':
                    first_plus_appeared = True
                    continue

                parsed_email.append(c)
            return "".join(parsed_email)

        unique_emails = set()
        for email in emails:
            parsed_email = parse_email(email)
            unique_emails.add(parsed_email)
        
        return len(unique_emails)
```

## Step3
```py
class Solution:
    def numUniqueEmails(self, emails: List[str]) -> int:
        def parse_email(email):
            local_name, domain_name = email.split('@', maxsplit=1)
            if not local_name or not domain_name:
                return
            
            if local_name[0] == '+':
                return

            if not domain_name.endswith(".com"):
                return

            if domain_name[:-4] == "":
                return

            parsed_local_name = local_name.split('+')[0].replace('.', '')
            return parsed_local_name + '@' + domain_name
        
        unique_emails = set()
        for email in emails:
            parsed_email = parse_email(email)
            if parsed_email is None:
                continue
            
            unique_emails.add(parsed_email)

        return len(unique_emails)
```