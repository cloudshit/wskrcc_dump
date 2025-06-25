package org.worldskills.cloud.skillsbackend;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@SpringBootApplication
@RestController
public class SkillsBackendApplication {
    private final Logger log = LoggerFactory.getLogger(this.getClass().getSimpleName());

    public static void main(String[] args) {
        SpringApplication.run(SkillsBackendApplication.class, args);
    }

    @GetMapping("/api/")
    public ResponseEntity<String> index() {
        String text = "Hello, World!";

        log.info("GET | /api/ |200");

        return new ResponseEntity<>(text, HttpStatus.OK);
    }

    @GetMapping("/api/time")
    public ResponseEntity<Map<String, Object>> time() {
        Map<String, Object> data = new HashMap<>();

        LocalDateTime currentDateTime = LocalDateTime.now();

        data.put("time", currentDateTime);

        log.info("GET | /api/time | 200");

        return new ResponseEntity<>(data, HttpStatus.OK);
    }

    @GetMapping("/api/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> data = new HashMap<>();
        data.put("status", "OK");

        log.info("GET | /api/health | 200");

        return new ResponseEntity<>(data, HttpStatus.OK);
    }
}
