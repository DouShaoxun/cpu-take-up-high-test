package cn.cruder.ctuh.runner;


import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * @author dousx
 * @date 2022-05-06 16:45
 */
@Component
public class AppRunner implements ApplicationRunner {
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(AppRunner.class);

    @Override
    public void run(ApplicationArguments args) throws Exception {
        TimeUnit.SECONDS.sleep(5);
        for (int i = 0; i < 10000; i++) {
            int random = BigDecimal.valueOf(Math.random() * 1000).intValue();
            while (random < 1000) {
                random = random * 10;
            }
        }
    }
}
