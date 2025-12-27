<div align="center">
<pre style="color:#fc03d7;">
 _____           _ _          
|  __ \         | | |         
| |__) |__ _  __| | |__   ___ 
|  _  // _` |/ _` | '_ \ / _ \
| | \ \ (_| | (_| | | | |  __/
|_|  \_\__,_|\__,_|_| |_|\___|
</pre>
</div>
<hr>

### 1. Create project folder
```shell
cd ./your-project
```
### 2. Clone Repo
```shell
git clone https://github.com/Akhil-Biswas/py.git .
```
### 3. Run setup

```shell
chmod +x setup.sh
./setup.sh
```

### 4. Change remote to your repository
```shell
git remote remove origin
git remote add origin git@github.com:<your-username>/<your-repo>.git
```
### 5. Verify
```shell
git remote -v
```
```output.txt
# OUTPUT
origin  git@github.com:<your-username>/<your-repo>.git (fetch)
origin  git@github.com:<your-username>/<your-repo>.git (push)

```
