# Deploy manually

```bash
ssh dhp@34.126.130.128

cd ~/caremate/cengine-api
git pull --rebase --verbose

cd ~/caremate

docker compose down cengine-api
docker compose build cengine-api
docker compose up -d cengine-api

docker compose logs --follow cengine-api
```
