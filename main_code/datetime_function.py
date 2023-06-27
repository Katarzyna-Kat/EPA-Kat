from datetime import datetime, timedelta
import datetime

# dateLimit = datetime.datetime(2023, 6, 24)
# dateEmail = datetime.datetime(2023, 6, 28)


dateToday = datetime.datetime.now()


def date_limit_function(today_date):
    dateDiff = today_date - timedelta(days = 5)
    dateDiffEmail = today_date - timedelta(days = 2)
    return [dateDiff, dateDiffEmail]