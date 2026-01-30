// Fantasy Skill Bar - Stile Metin2

//  VARIABILI GLOBALI
let currentForm = null;
let isBarVisible = false;

// CONFIGURAZIONE SPELL PER FORMA CO ICONE WINDOWS
const spellConfig = {
    vampire: {
        1: { name: 'Blood Thirst', icon: '🩸', key: '6' },
        2: { name: 'Mist Form', icon: '🌫️', key: '7' },
        3: { name: 'Hypnosis', icon: '👁️', key: '8' },
        4: { name: 'Vampire Bite', icon: '🦇', key: '9' },
        5: { name: 'Bat Swarm', icon: '🦇', key: '0' }
    },
    lycan: {
        1: { name: 'Rage', icon: '🐺', key: '6' },
        2: { name: 'Claw Attack', icon: '⚔️', key: '7' },
        3: { name: 'Howl', icon: '🌕', key: '8' },
        4: { name: 'Lycan Bite', icon: '🦷', key: '9' },
        5: { name: 'Full Moon', icon: '🌙', key: '0' }
    },
    animagus: {
        1: { name: 'Swift', icon: '🦌', key: '6' },
        2: { name: 'Stealth', icon: '👤', key: '7' },
        3: { name: 'Escape', icon: '💨', key: '8' },
        4: { name: 'Track', icon: '🐾', key: '9' },
        5: { name: 'Keen Senses', icon: '👁️', key: '0' }
    }
};

//  MESSAGE HANDLER
window.addEventListener('message', function(event) {
    console.log('[DEBUG] Message received from FiveM:', event.data);
    
    const data = event.data;
    
    switch (data.action) {
        case 'show':
            console.log('[DEBUG] Action: show - Calling showSkillBar');
            showSkillBar(data.form, data.spells, data.noFocus);
            break;
        case 'hide':
            console.log('[DEBUG] Action: hide - Calling hideSkillBar');
            hideSkillBar();
            break;
        case 'updateCooldown':
            console.log('[DEBUG] Action: updateCooldown');
            updateCooldown(data.slot, data.remaining);
            break;
        case 'castAnimation':
            console.log('[DEBUG] Action: castAnimation');
            playCastAnimation(data.slot);
            break;
        default:
            console.log('[DEBUG] Unknown action:', data.action);
    }
});

//  FUNZIONE PER MOSTRARE LA SKILL BAR
function showSkillBar(form, spells, noFocus = false) {
    console.log('[DEBUG] Showing skill bar for form:', form, 'noFocus:', noFocus);
    
    currentForm = form;
    isBarVisible = true;
    
    const skillBar = document.getElementById('skillBar');
    if (!skillBar) {
        console.error('[ERROR] Skill bar element not found');
        return;
    }
    
    // Rimuovi classi tema esistenti
    skillBar.className = '';
    
    // Aggiungi tema in base alla forma
    if (form === 'vampire') {
        skillBar.classList.add('vampire');
    } else if (form === 'lycan') {
        skillBar.classList.add('lycan');
    } else if (form === 'animagus') {
        skillBar.classList.add('animagus');
    }
    
    // Aggiorna spell se fornite
    if (spells) {
        updateSpells(spells);
    }
    
    // Mostra la skill bar
    skillBar.style.display = 'flex';
    
    console.log('[DEBUG] Skill bar shown successfully');
}

// FUNZIONE PER NASCONDERE LA SKILL BAR
function hideSkillBar() {
    console.log('[DEBUG] Hiding skill bar');
    
    isBarVisible = false;
    currentForm = null;
    
    const skillBar = document.getElementById('skillBar');
    if (skillBar) {
        skillBar.classList.add('hidden');
    }
    
    console.log('[DEBUG] Skill bar hidden');
}

//  FUNZIONE PER AGGIORNARE LE SPELL
function updateSpells(form) {
    console.log('[DEBUG] Updating spells for form:', form);
    
    const spells = spellConfig[form];
    if (!spells) {
        console.error('[ERROR] No spells found for form:', form);
        return;
    }
    
    // Aggiorna ogni slot
    for (let slot = 1; slot <= 5; slot++) {
        const slotElement = document.querySelector(`[data-slot="${slot}"]`);
        if (!slotElement) continue;
        
        const spell = spells[slot];
        const iconElement = slotElement.querySelector('.skill-icon');
        const nameElement = slotElement.querySelector('.skill-name');
        const keyElement = slotElement.querySelector('.skill-key');
        
        if (spell) {
            iconElement.textContent = spell.icon;
            iconElement.classList.remove('empty');
            nameElement.textContent = spell.name;
            keyElement.textContent = spell.key;
        } else {
            iconElement.textContent = '?';
            iconElement.classList.add('empty');
            nameElement.textContent = '-';
            keyElement.textContent = (5 + parseInt(slot)).toString();
        }
    }
    
    console.log('[DEBUG] Spells updated successfully');
}

//  FUNZIONE PER AGGIORNARE IL COOLDOWN
function updateCooldown(slot, remaining) {
    console.log('[DEBUG] Updating cooldown for slot', slot, 'remaining:', remaining);
    
    const slotElement = document.querySelector(`[data-slot="${slot}"]`);
    if (!slotElement) return;
    
    const cooldownOverlay = slotElement.querySelector('.cooldown-overlay');
    if (!cooldownOverlay) return;
    
    if (remaining > 0) {
        // Mostra cooldown
        cooldownOverlay.classList.add('active');
        
        // Crea o aggiorna il timer
        let timerElement = cooldownOverlay.querySelector('.cooldown-timer');
        if (!timerElement) {
            timerElement = document.createElement('div');
            timerElement.className = 'cooldown-timer';
            cooldownOverlay.appendChild(timerElement);
        }
        
        // Aggiorna il timer
        const updateTimer = () => {
            const seconds = Math.ceil(remaining / 1000);
            timerElement.textContent = seconds.toString();
            
            if (remaining > 0) {
                remaining -= 1000;
                setTimeout(updateTimer, 1000);
            } else {
                // Nascondi cooldown
                cooldownOverlay.classList.remove('active');
                timerElement.remove();
            }
        };
        
        updateTimer();
    } else {
        // Nascondi cooldown
        cooldownOverlay.classList.remove('active');
        const timerElement = cooldownOverlay.querySelector('.cooldown-timer');
        if (timerElement) {
            timerElement.remove();
        }
    }
}

//  FUNZIONE PER ANIMAZIONE DI CAST
function playCastAnimation(slot) {
    console.log('[DEBUG] Playing cast animation for slot', slot);
    
    const slotElement = document.querySelector(`[data-slot="${slot}"]`);
    if (!slotElement) return;
    
    // Aggiungi classe di animazione
    slotElement.classList.add('casting');
    
    // Rimuovi dopo l'animazione
    setTimeout(() => {
        slotElement.classList.remove('casting');
    }, 500);
}

//  CLICK HANDLER PER GLI SLOT
document.addEventListener('DOMContentLoaded', function() {
    console.log('[DEBUG] DOM loaded, setting up click handlers');
    
    // Aggiungi click handler a tutti gli slot
    for (let slot = 1; slot <= 5; slot++) {
        const slotElement = document.querySelector(`[data-slot="${slot}"]`);
        if (slotElement) {
            slotElement.addEventListener('click', function() {
                console.log('[DEBUG] Slot', slot, 'clicked');
                
                // Invia evento al client
                fetch(`https://fantasy_skilltree/castSpell`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: JSON.stringify({
                        slot: slot
                    })
                }).catch(error => {
                    console.error('[ERROR] Failed to send cast event:', error);
                });
            });
        }
    }
});

console.log('[DEBUG] Fantasy Skill Bar loaded successfully');
