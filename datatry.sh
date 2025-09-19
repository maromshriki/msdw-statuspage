#!/bin/bash
set -e  # עצירה במקרה של שגיאה

# הגדרות בסיס
DB_HOST="msdw-database-1.cx248m4we6k7.us-east-1.rds.amazonaws.com"
DB_NAME="statuspage"
DB_USER="statuspage"
DB_PASS="msdw"

export PGPASSWORD=$DB_PASS

echo "בודק חיבור ל-RDS..."
pg_isready -h $DB_HOST -p 5432 -U $DB_USER
if [ $? -ne 0 ]; then
    echo "ERROR: לא מצליחים להתחבר ל-RDS. בדוק Security Group ופרטי חיבור."
    exit 1
fi
echo "חיבור ל-RDS תקין ✅"

echo "מריצים מיגרציות Django עם verbosity גבוה..."
python3 statuspage/manage.py migrate --verbosity 2

echo "המיגרציות הסתיימו בהצלחה 🎉"

