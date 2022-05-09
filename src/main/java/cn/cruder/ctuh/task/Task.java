package cn.cruder.ctuh.task;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * @author dousx
 * @date 2022-05-09 18:58
 */
@Component
public class Task {
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(Task.class);


    @Scheduled(cron = "*/10 * * * * ?")
    public void taskAddByte() {
        log.info(new Date());
    }
}
