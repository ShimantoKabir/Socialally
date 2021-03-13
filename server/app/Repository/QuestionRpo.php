<?php

namespace App\Repository;

use App\Models\AppConstant;
use Exception;
use App\Models\Question;
use App\Utilities\AppConstantReader;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class QuestionRpo
{

    public function readByTime(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            if (!$request->has('time-of-day')) {
                $res['code'] = 404;
                $res['msg'] = "Time of the day required!";
            } else {

                $timeOfDay = $request->query('time-of-day');

                $appConstant = AppConstantReader::read();
                $res['questionShowingTime'] = $appConstant["questionShowingTime"];

                $qst = str_replace(' ', '', $res['questionShowingTime']);

                if ($timeOfDay == $qst) {
                    $sql = "SELECT * FROM Questions ORDER BY id DESC LIMIT 0,5";
                    $res['questions'] = DB::select(DB::raw($sql));
                    $res["code"] = 200;
                    $res['msg'] = "Question fetched successfully!";
                } else {
                    $res['questions'] = [];
                    $res["code"] = 200;
                    $res['msg'] = "Question showing time not come yet!";
                }
            }
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function create(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rQuestion = $request->question;
        DB::beginTransaction();
        try {

            $question = new Question();
            $question->question = $rQuestion['question'];
            $question->save();

            $res["code"] = 200;
            $res['msg'] = "Question save successfully!";
            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function update(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        $rQuestion = $request->question;
        DB::beginTransaction();
        try {

            Question::where("id", $rQuestion['id'])->update([
                "question" => $rQuestion['question']
            ]);

            $res["code"] = 200;
            $res['msg'] = "Question updated successfully!";
            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function delete(Request $request, $id)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        DB::beginTransaction();
        try {

            Question::where("id", $id)->delete();

            $res["code"] = 200;
            $res['msg'] = "Question deleted successfully!";
            DB::commit();
        } catch (Exception $e) {
            DB::rollBack();
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }

    public function readByQuery(Request $request)
    {

        $res = [
            "msg" => "",
            "code" => ""
        ];

        try {

            if (!$request->has('par-page')) {
                $res['code'] = 404;
                $res['msg'] = "Par page required!";
            } else if (!$request->has('page-index')) {
                $res['code'] = 404;
                $res['msg'] = "Page index required!";
            } else {

                $parPage = $request->query('par-page');
                $pageIndex = $request->query('page-index');

                $sql = "SELECT 
                            *
                        FROM 
                            Questions
                        ORDER BY 
                            id DESC 
                        LIMIT 
                            " . $pageIndex . ", " . $parPage;

                $res['questions'] = DB::select(DB::raw($sql));
                $res['msg'] = "Questions fetched successfully!";
                $res['code'] = 200;
            }
        } catch (Exception $e) {
            $res['msg'] = $e->getMessage();
            $res['code'] = $e->getCode();
        }

        return $res;
    }
}
