package kr.ac.kumoh.oiyo.mydiaryback;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableJpaAuditing
@EnableScheduling
public class MyDiaryBackApplication {
    public static void main(String[] args) {
        SpringApplication.run(MyDiaryBackApplication.class, args);
    }
}
