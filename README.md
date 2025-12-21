# 🖥️ Self-Healing System Monitor

A lightweight system monitoring tool that automatically detects issues and fixes them. Built with Bash and vanilla web technologies.

![Dashboard](/home/akash/Pictures/Screenshots/Pro.png)

## Why This Exists

Tired of services crashing at 3 AM? This tool monitors your system health and automatically restarts failed services—no manual intervention needed.

## Features

- **Real-time monitoring** of CPU, Memory, and Disk usage
- **Self-healing** - automatically restarts Docker daemon when it crashes
- **Smart alerts** with 5-minute cooldown to prevent spam
- **Historical tracking** with interactive charts
- **Clean dashboard** with live updates every 10 seconds

## Quick Start

```bash
# 1. Clone and setup
git clone https://github.com/akash0-real/system-monitor.git
cd system-monitor
chmod +x analyse.sh

# 2. Create data directory
mkdir -p data

# 3. Test it
./analyse.sh

# 4. Automate it (runs every 5 minutes)
crontab -e
# Add this line:
*/5 * * * * /path/to/system-monitor/analyse.sh >> /path/to/system-monitor/data/cron.log 2>&1

# 5. View dashboard
python3 -m http.server 8000
# Open: http://localhost:8000/dashboard.html
```

## How It Works

```
Cron (every 5 min) → analyse.sh → Collects metrics → Checks thresholds
                                       ↓
                    If critical: Log alert + Self-heal
                                       ↓
                    Save to: metrics.json, metric.csv, alert.log
                                       ↓
                    Dashboard reads files → Displays charts
```

## Configuration

Edit thresholds in `analyse.sh`:

```bash
# Alert thresholds (percentage)
cpu_warn=80     # Warning level
cpu_cri=90      # Critical level
mem_warn=80
mem_cri=90
disk_warn=80
disk_cri=90

cooldown=300    # Alert cooldown (5 minutes)
```

## Project Structure

```
monitor/
├── analyse.sh         # Monitoring script
├── dashboard.html     # Web dashboard
└── data/
    ├── metrics.json   # Current state
    ├── metric.csv     # Historical data
    └── alert.log      # Alert history
```

## Self-Healing Example

When Docker crashes, the script automatically:

1. Detects the failure
2. Restarts Docker daemon
3. Verifies it's running
4. Logs the recovery

```bash
if ! pgrep -x "dockerd" > /dev/null; then
  sudo systemctl restart docker
  # Verify restart succeeded
  if pgrep -x "dockerd" > /dev/null; then
    echo "[info] docker daemon recovered"
  fi
fi
```

## Dashboard Features

- **Live metrics** with color-coded states (NORMAL/WARNING/CRITICAL)
- **Trend charts** showing last 20 data points
- **Alert history** with timestamps
- **Auto-refresh** every 10 seconds

## Security Note

For Docker auto-restart, add to sudoers (use `visudo`):

```bash
your_username ALL=(ALL) NOPASSWD: /bin/systemctl restart docker
```

## What's Next

Planning to add:
- Email/Slack notifications
- Multi-server support
- Prometheus export format
- Network latency monitoring

## Tech Stack

- **Backend**: Bash scripting
- **Automation**: Cron
- **Frontend**: HTML/CSS/JavaScript
- **Charts**: Chart.js
- **Data**: JSON, CSV

## Contributing

Found a bug or have an idea? Open an issue or submit a PR!

## License

MIT License - feel free to use this however you want.

## Contact

**Akash** - aayush45@gmail.com

GitHub: [@akash0-real](https://github.com/akash0-real)

---

Built with ❤️ and Bash | If this helped you, give it a ⭐
