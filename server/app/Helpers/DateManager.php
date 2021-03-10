<?php

namespace App\Helpers;

use DateTime;
use DatePeriod;
use DateInterval;

class DateManager
{

    public static function getDatesFromRange($start, $end, $format = 'Y-m-d')
    {

        $array = array();

        $interval = new DateInterval('P1D');
        $realEnd = new DateTime($end);
        $realEnd->add($interval);

        $period = new DatePeriod(new DateTime($start), $interval, $realEnd);

        foreach ($period as $date) {
            $array[] = $date->format($format);
        }

        return $array;
    }
}
