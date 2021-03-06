import 'package:wengine/widgets/WelcomeNavBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            WelcomeNavBar(),
            Container(
              padding: EdgeInsets.all(40),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      "About Us",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    ),
                    decoration: headerDecoration(),
                  ),
                  SizedBox(height: 10),
                  Text(
                      "WorkersEngine is an innovative crowdsources platform that connects Employer as well as Workers globally. WorkersEngine is a UK based registered company with registration number 13162011 is registered as WorkersEngine Ltd. We offer effective solutions to companies, businesses and persons in need to outsource their jobs and projects. Solutions may include constructive ways of breaking down vast tasks to be distributed to workers, minimizing your time to finish your project and collect results on your target date. Our platform concentrates in deploying micro jobs to workers such as data collection and analysis, moderation and/or extraction of data, annotation, classification, image or video tagging, conversion and transcription, product testing, research and survey jobs and more. WorkersEngine began in 2021 and is now one of the growing and trusted crowd-based outsourcing platforms online.",
                    style: TextStyle(
                      letterSpacing: 0.5,
                      height: 1.5,
                      fontSize: 16
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Text(
                      "Our Team",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    ),
                    decoration: headerDecoration(),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "WorkersEngine consists of an enthusiastic team, which have high skill in project solutions, supplying customer value and quality assurance. We dedicate our time to provide our users with the exceptional service they deserve.",
                    style: TextStyle(
                        letterSpacing: 0.5,
                        height: 1.5,
                        fontSize: 16
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Text(
                      "How It Works",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    ),
                    decoration: headerDecoration(),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Here in WorkersEngine, you can be an Employer and/or a Worker.",
                    style: TextStyle(
                        letterSpacing: 0.5,
                        height: 1.5,
                        fontSize: 16
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.circle,size: 10),
                            SizedBox(width: 10),
                            Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      letterSpacing: 0.5,
                                      height: 1.5,
                                      color: Colors.black
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: 'As an employee, ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: 'you can post a job or offer jobs by creating campaigns and ran them to your chosen group of skilled workers or selected workers from a specified chosen country.')
                                    ],
                                  ),
                                )
                            )
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.circle,size: 10),
                            SizedBox(width: 10),
                            Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                        letterSpacing: 0.5,
                                        height: 1.5,
                                        color: Colors.black
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(text: 'As a Worker, ', style: new TextStyle(fontWeight: FontWeight.bold)),
                                      TextSpan(text: 'you can earn money by doing micro jobs available for you. You can perform jobs anytime and there is no limit to how many jobs you can accept. If you have special skills, you can be included in our predefined group of workers where you can be offered special and interesting jobs and earn more money. Once you perform a task, it will then be reviewed and rated by the Employers. You will earn money when your task is rated as "Satisfied"')
                                    ],
                                  ),
                                )
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    child: Text(
                      "Our Workers",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 30
                      ),
                    ),
                    decoration: headerDecoration(),
                  ),
                  SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          letterSpacing: 0.5,
                          height: 1.5,
                          color: Colors.black,
                        fontSize: 16
                      ),
                      children: <TextSpan>[
                        TextSpan(text: 'Our workers, whom we call '),
                        TextSpan(text: 'WorkersEngine, ', style: new TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: 'contribute productively by performing tasks offered by the Employers.')
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Our WorkersEngine come from various walks of life, from all around the world, starting from students at their legal age to professionals or freelancers who wants to have an additional income online.",
                    style: TextStyle(
                        letterSpacing: 0.5,
                        height: 1.5,
                        fontSize: 16
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "To ensure quality of service, our WorkersEngine undergo Qualification Tests and are being regrouped to be included in workers with specific and special skills.",
                    style: TextStyle(
                        letterSpacing: 0.5,
                        height: 1.5,
                        fontSize: 16
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )
    );
  }

  BoxDecoration headerDecoration() {
    return BoxDecoration(
      border: Border(
        bottom:  BorderSide(
          color: Colors.green,
          width: 3.0,
        )
      ),
    );
  }

}