# 04 Generate random users & weak passwords

1. Determine some schema thats fits for me.```ad_schema.json```
2. Search for random first, last names, weak passwords, like [this](https://github.com/danielmiessler/SecLists/blob/master/Passwords/Leaked-Databases/rockyou-20.txt).
3. Create ```gen_ad.ps1``` script as generator ADUser and ADGroup, which takes as parameter json file with random users data.
4. Generate random users data from given txt files in ```random_domains.ps1```