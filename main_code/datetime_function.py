from datetime import datetime, timedelta
import datetime


dateToday = datetime.datetime.now()


def date_limit_function(today_date):
    dateDiff = today_date - timedelta(days = 5)
    dateDiffEmail = today_date - timedelta(days = 2)
    return [dateDiff, dateDiffEmail]