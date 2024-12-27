document.addEventListener('DOMContentLoaded', function() {
    const syncMessageDiv = document.getElementById('sync-message');
    const jobMessageDiv = document.getElementById('job-message');

    function showSyncMessage() {
        if (syncMessageDiv) {
            syncMessageDiv.innerText = '同期中です...';
            syncMessageDiv.style.display = 'block';
        }
    }

    function hideSyncMessage() {
        if (syncMessageDiv) {
            syncMessageDiv.style.display = 'none';
        }
    }

    function showJobMessage() {
        if (jobMessageDiv) {
            jobMessageDiv.style.display = 'block';
        }
    }

    function hideJobMessage() {
        if (jobMessageDiv) {
            jobMessageDiv.style.display = 'none';
        }
    }

    window.showSyncMessage = showSyncMessage;
    window.hideSyncMessage = hideSyncMessage;
    window.showJobMessage = showJobMessage;
    window.hideJobMessage = hideJobMessage;
});

document.addEventListener('DOMContentLoaded', function() {
    const jobMessageDiv = document.createElement('div');
    jobMessageDiv.id = 'job-message';
    jobMessageDiv.style.display = 'none';
    jobMessageDiv.innerText = 'ジョブを実行中です。完了するまで操作しないでください。';
    document.body.appendChild(jobMessageDiv);

    function showJobMessage() {
        jobMessageDiv.style.display = 'block';
    }

    function hideJobMessage() {
        jobMessageDiv.style.display = 'none';
    }

    window.showJobMessage = showJobMessage;
    window.hideJobMessage = hideJobMessage;
});