package com.example.gcthrasher;

import java.util.LinkedList;
import java.util.List;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GcThrasherController {
    private static final Logger LOG = LogManager.getLogger(GcThrasherController.class);

    @Value("${gc.thrash.block.size}")
    private int gcThrashblockSize;

    @Value("${gc.thrash.retries}")
    private int gcThrashRetries;

    @GetMapping("/gcthrash")
    public String gcThrash(
            @RequestParam(required = false) Integer blockSize,
            @RequestParam(required = false) Integer retries) {
        if (blockSize != null) {
            gcThrashblockSize = blockSize;
        }
        if (retries != null) {
            gcThrashRetries = retries;
        }
        LOG.info("%%% GC Thrash - begin %%%");
        LOG.info("GC block size = " + gcThrashblockSize);
        final List<byte[]> list = new LinkedList<>();
        try {
            for (;;) {
                list.add(new byte[gcThrashblockSize]);
                if (list.size() % 1000 == 0) {
                    LOG.info("GC block count = " + list.size());
                }
            }
        } catch (final OutOfMemoryError e) {
            // Ignore
        }

        // free some memory
        list.remove(0);
        list.remove(0);
        LOG.info("GC block count = " + (list.size() + 3) + " -- Memory full");

        LOG.info("GC thrash count = " + gcThrashRetries);
        for (int i = 0; i < gcThrashRetries; i++) {
            list.add(new byte[gcThrashblockSize]);
            list.remove(0);
            if (i % 10 == 0) {
                LOG.info("GC activity count = " + i);
            }
        }
        LOG.info("%%% GC Thrash - end %%%");
        return "Thrashing complete";
    }
}
